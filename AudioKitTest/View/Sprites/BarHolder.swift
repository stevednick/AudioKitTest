//
//  BarHolder.swift
//  Farkas
//
//  Created by Stephen Nicholls on 11/02/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import SpriteKit

class BarHolder: SKSpriteNode{ // Think about how to adjust this to make it more flexible
    
    let noteHolder = NoteHolder()
    let clef = clefHolder()
    var crotchetRest = SKSpriteNode()  // Move this to own class soon..
    let minimRest = MinimRestHolder()
    let frontBarLine = BarLine()
    var clefShowing = true
    let barLength = 400
    var lastClef = "null"
    var currentClef = "null"
    var noteTop: CGFloat = 0.0
    var noteShowing: note = note(pos: 0, accidental: "null")
    
    init(last: String, _ manualNote: note = note(pos: -1000, accidental: "null")){
        super.init(texture: nil, color: .clear, size: CGSize.zero)
        lastClef = last
        load(manualNote: manualNote)
        getNoteTop()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func stoppedNote(){
        noteHolder.displayStop(stopped: true)
        getNoteTop()
    }
    
    func getNoteTop(){
        noteTop = noteHolder.noteTop
    }
    
    func sortCrotchetRest(){
        crotchetRest = SKSpriteNode(imageNamed: "crotchetRest")
        crotchetRest.color = .black
        crotchetRest.colorBlendFactor = 1
        crotchetRest.size = CGSize(width: 30, height: 80)
        addChild(crotchetRest)
    }
    
    func load(manualNote: note){
        addChild(noteHolder)
        addChild(frontBarLine)
        changeNote(manualNote: manualNote)
        if clefShowing{
            addChild(clef)
            clef.position = CGPoint(x: -120, y: 0)
        }
        addChild(minimRest)
        sortCrotchetRest()
        crotchetRest.position = CGPoint(x: 80, y: 0)
        minimRest.position = CGPoint(x: 170, y: 0)
        frontBarLine.position = CGPoint(x: -75, y: 0)
    }
    
    func changeNote(manualNote: note){ // feed note into this to be displayed if one is missed.
        var n = NoteController().getRandomNote() // sort getRandomNote to send all in one note.
        if manualNote.pos > -100{
            n = manualNote
            if n.flashing{
                noteHolder.flashing()
            }
            
        }
        noteShowing = n
        currentClef = n.clef
        clefShowing = lastClef != currentClef
        sortClefAndNote(clefHolder: clef, noteHolder: noteHolder, note: n)
    }
    
    func sortClefAndNote(clefHolder: clefHolder, noteHolder: NoteHolder, note: note){
        clef.displayClef(clef: note.clef)
        noteHolder.display(note: note)
    }
    
    func dissapearNote(){
        let fadeOutTime: TimeInterval = 1
        let fadeOutAction = SKAction.fadeOut(withDuration: fadeOutTime)
        noteHolder.run(fadeOutAction)
    }
    
    func getCurrentNote() -> note{
        return noteShowing
    }
}
