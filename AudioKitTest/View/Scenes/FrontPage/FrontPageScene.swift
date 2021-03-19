//
//  FrontPageScene.swift
//  Farkas
//
//  Created by Stephen Nicholls on 29/01/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

class FrontPageScene: SKScene {
    let noteController = NoteController()
    weak var viewController: FrontPageViewController!
    var visibleAreaEdge: CGFloat = 0
    let stave = staveHolder()
    let topNote = NoteHolder()
    let topClef = clefHolder()
    let bottomNote = NoteHolder()
    let bottomClef = clefHolder()
    let barLine = BarLine()
    let frontBarLine = BarLine()
    var ball = BouncyBall() // Testing
    var topNotePosX: CGFloat = 0.0
    var bottomNotePosX: CGFloat = 0.0
    var topNotePos = 0
    var rangeText = SKLabelNode(text: "Range:")
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        addChild(stave)
        addChild(topNote)
        addChild(topClef)
        addChild(bottomNote)
        addChild(bottomClef)
        addChild(barLine)
        addChild(frontBarLine)
        
        addChild(ball) // Testing
        
        sortRangeText()
        //ball.position = CGPoint(x: -100, y: Data().lineGap * 2 + 8)
        frontBarLine.position = CGPoint(x: 0, y: 0)
        //topNotePosX = size.width/2 - 335
        //bottomNotePosX = size.width/2 - 235
        stave.position = CGPoint(x: 1000, y: 0)
        topClef.position = CGPoint(x: 50, y: 0)
        topNote.position = CGPoint(x: 160, y: 0)
        bottomClef.position = CGPoint(x: 250, y: 0)
        bottomNote.position = CGPoint(x: 350, y: 0)
        topNote.showArrows()
        bottomNote.showArrows()
        barLine.position = bottomClef.position
        displayNotes()
        
    }
    
    func sortRangeText(){
        rangeText.setUp(size: 36)
        //rangeText.position = CGPoint(x: 90, y: 140)
        addChild(rangeText)
    }

    
    func sortClefAndNote(clefHolder: clefHolder, noteHolder: NoteHolder, note: note){
        clefHolder.displayClef(clef: note.clef)
        noteHolder.display(note: note)
    }
    
    func displayNotes(){
        let (top, bottom) = noteController.getTopAndBottomNote()
        topNotePos = top.pos
        sortClefAndNote(clefHolder: topClef, noteHolder: topNote, note: top)
        sortClefAndNote(clefHolder: bottomClef, noteHolder: bottomNote, note: bottom)
        bottomClef.isHidden = top.clef == bottom.clef
        barLine.isHidden = top.clef != bottom.clef
    }
    
    override func update(_ currentTime: TimeInterval) {
        ball.regularBounce(currentTime: currentTime)
    }
    
    func resetBall(){ // all for testing, dont forget call to this in viewController.
        
        ball.removeFromParent()
        ball = BouncyBall()
        addChild(ball)
        ball.position = CGPoint(x: 0, y: Data().lineGap * 2 + 12)
 
    }
    
    func getNotePositions() -> (CGFloat, CGFloat){
        let topNotePos = topNote.position.x / (size.width/2)
        let bottomNotePos = bottomNote.position.x / (size.width/2)
        return (topNotePos, bottomNotePos)
    }
}
