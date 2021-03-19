//
//  NoteHolder.swift
//  Farkas
//
//  Created by Stephen Nicholls on 25/01/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit



class NoteHolder: SKSpriteNode, SKPhysicsContactDelegate{ // Is this a contact delegate?
    
    var noteController = NoteController()
    let noteHolder = SKSpriteNode()
    let crotchet = SKSpriteNode(imageNamed: "crotchet")
    let invertedCrotchet = SKSpriteNode(imageNamed: "crotchet")
    let sharp = SKSpriteNode(imageNamed: "sharp2")
    let flat = SKSpriteNode(imageNamed: "flat")
    let doubleSharp = SKSpriteNode(imageNamed: "DoubleSharp")
    let doubleFlat = SKSpriteNode(imageNamed: "DoubleFlat")
    let plus = SKSpriteNode(imageNamed: "plus")
    let arrow = SKSpriteNode(imageNamed: "arrows")
    var topLedgers: [SKShapeNode] = [SKShapeNode]()
    var bottomLedgers: [SKShapeNode] = [SKShapeNode]()
    let ledgerLength: CGFloat = 55
    var noteTop: CGFloat = 0.0
    var currentNote: note = note(pos: 0, accidental: "null") // store note when initialised here.
    var displayArrow = false
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: nil, color: .clear, size: noteHolder.size)
        let note = noteController.getRandomNote()
        setUpNote(note: note)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpNote(note: note){ // sort all the bits
        setUpSprite(sprite: crotchet, size: CGSize(width: 30, height: 100), anchor: CGPoint(x: 0.5, y: 0.12))
        setUpSprite(sprite: invertedCrotchet, size: CGSize(width: 30, height: 100), anchor: CGPoint(x: 0.5, y: 0.125))
        setUpSprite(sprite: sharp, size: CGSize(width: 30, height: 60), anchor: CGPoint(x: 0.5, y: 0.45))
        setUpSprite(sprite: flat, size: CGSize(width: 25, height: 55), anchor: CGPoint(x: 0.5, y: 0.25))
        setUpSprite(sprite: doubleSharp, size: CGSize(width: 28, height: 30), anchor: CGPoint(x: 0.5, y: 0.5))
        setUpSprite(sprite: doubleFlat, size: CGSize(width: 40, height: 55), anchor: CGPoint(x: 0.5, y: 0.28))
        setUpSprite(sprite: arrow, size: CGSize(width: 20, height: 38), anchor: CGPoint(x: 0.5, y: 0.5))
        arrow.color = .systemBlue
        arrow.isHidden = true
        setUpSprite(sprite: plus, size: CGSize(width: 30, height: 30), anchor: CGPoint(x: 0.5, y: 0.5))
        invertedCrotchet.zRotation = .pi
        initLedgers()
        display(note: note)
    }
    
    func showArrows(){
        arrow.isHidden = false
    }
    
    func setNoteTop(note: note) -> CGFloat{
        var distanceFromTop = 0
        if note.pos <= 0{
            distanceFromTop = note.pos + 3
        }else{
            distanceFromTop = note.pos - 3
        }
        if distanceFromTop > 0{
            let noteTop = CGFloat(distanceFromTop) * (Data().lineGap / 2)
            setStopPosition(noteTop: noteTop)
            return noteTop
        }
        setStopPosition(noteTop: 0)
        return 0.0
    }
    
    func setStopPosition(noteTop: CGFloat){
        plus.position = CGPoint(x: 0, y: noteTop + Data().lineGap * 3)
        plus.isHidden = true
    }
    
    func displayStop(stopped: Bool){
        plus.isHidden = !stopped
        if stopped{
            noteTop += Data().lineGap * 1.5
        }
    }
    
    func changeColour(colour: SKColor){
        if crotchet.color != colour{
            for sprite in [crotchet, invertedCrotchet, sharp, flat]{
                sprite.color = colour
            }
        }
    }
    
    func flashing(){
        let flashDuration = 0.5
        let toRed = SKAction.run {
            self.crotchet.color = .red
            self.invertedCrotchet.color = .red
        }
        let toBlack = SKAction.run {
            self.crotchet.color = .black
            self.invertedCrotchet.color = .black
        }
        let waitAction = SKAction.wait(forDuration: flashDuration)
        let flashes = [toRed, SKAction.wait(forDuration: 0.2), toBlack, waitAction]
        let actionToRepeat = SKAction.sequence(flashes)
        run(SKAction.repeatForever(actionToRepeat))
    }
    
    func displayBits(note: note){
        invertedCrotchet.isHidden = note.pos <= 0
        crotchet.isHidden = note.pos > 0
        for accAndName in [sharp: "sharp", flat: "flat", doubleSharp: "doubleSharp", doubleFlat: "doubleFlat"]{
            accAndName.key.isHidden = note.accidental != accAndName.value
        }
    }
    
    func displayLedgers(note:note){
        
        for i in 0..<topLedgers.count{
            topLedgers[i].isHidden = note.pos < 6 + (i * 2)
            bottomLedgers[i].isHidden = note.pos > -6 - (i * 2)
        }
    }
    
    func setUpSprite(sprite: SKSpriteNode, size: CGSize, anchor: CGPoint){
        addChild(sprite)
        sprite.color = Data().objectColour
        sprite.colorBlendFactor = 1
        sprite.size = size
        sprite.anchorPoint = anchor
    }
    
    func display(note: note){ // positioning
        let yPos: CGFloat = CGFloat(note.pos) * Data().lineGap/2
        crotchet.position = CGPoint(x: 0, y: yPos)
        arrow.position = CGPoint(x: 40, y: yPos)
        invertedCrotchet.position = CGPoint(x: 0, y: yPos)
        sharp.position = CGPoint(x: -40, y: yPos)
        flat.position = CGPoint(x: -32, y: yPos)
        doubleSharp.position = CGPoint(x: -35, y: yPos)
        doubleFlat.position = CGPoint(x: -38, y: yPos)
        displayBits(note: note)
        displayLedgers(note: note)
        noteTop = setNoteTop(note: note)
    }
    
    func initLedgers(){
        for i in 0...14{ // Change Number of ledgers here, or add to
            topLedgers.append(SKShapeNode())
            bottomLedgers.append(SKShapeNode())
            drawLine(ledger: topLedgers[i], positionY: Data().lineGap * CGFloat(3 + i))
            drawLine(ledger: bottomLedgers[i], positionY: Data().lineGap * -CGFloat(3 + i))
        }
    }
    
    func drawLine(ledger: SKShapeNode, positionY: CGFloat){
        let path = CGMutablePath()
        path.addRect(CGRect(x: -ledgerLength/2, y: 0, width: ledgerLength, height:Data().lineWidth))
        ledger.path = path
        ledger.fillColor = .black
        ledger.strokeColor = .black
        ledger.position = CGPoint(x: 0, y: positionY)
        addChild(ledger)
    }
}
