//
//  LongNoteScene.swift
//  Farkas
//
//  Created by Stephen Nicholls on 03/03/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import SpriteKit

class LongNoteScene: SKScene{
    
    weak var viewController: LongNoteViewController!
    
    let stave = staveHolder()
    let note = NoteHolder()
    let clef = clefHolder()
    let noteController = NoteController()
    var currentNoteNumber = 0
    //let lis = Listener()
    var heldNoteDuration = 0.0 // Add these 3 labels and save best time ever. 
    var bestTime = 0.0
    var bestEver = 0.0
    var startTime:TimeInterval = 0.0
    let data = UserDefaults.standard
    let timeToGreen = 60.0
    let thumbsUp = SKSpriteNode(imageNamed: "thumb")
    var forgiveness = 2
    var prevNoteArray: [Int] = [Int]() // test if this is necessary...
    
    let noteChecker = NoteChecker()
    var tooHighText = SKLabelNode(text: "Play Lower!")
    var tooLowText = SKLabelNode(text: "Play Higher!")
    
    override func didMove(to view: SKView) {
        addChild(stave)
        addChild(note)
        addChild(clef)
        sortThumb()
        sortLabels()
        note.position = CGPoint(x: 40, y: 0)
        note.showArrows()
        clef.position = CGPoint(x: -50, y: 0)
        changeNote()
        bestEver = data.double(forKey: Keys.bestHeldNoteTime)
        
    }
    
    func sortLabels(){
        func sort(label: SKLabelNode){
            label.setUp(size: 36)
            label.isHidden = true
            addChild(label)
            
        }
        sort(label: tooHighText)
        sort(label: tooLowText)
        tooHighText.position = CGPoint(x: 200, y: -120)
        tooLowText.position = CGPoint(x: 200, y: 100)
    }
    
    func sortThumb(){
        addChild(thumbsUp)
        thumbsUp.position = CGPoint(x: 120, y: 120)
        thumbsUp.size = CGSize(width: 100, height: 100)
        thumbsUp.isHidden = true
    }
    
    func setLabels(){
        viewController.bestTodayLabel.text = "Best Today: " + String(format:"%02.02f", bestTime)
        viewController.bestEverLabel.text = "Best Ever: " + String(format:"%02.02f", bestEver)
    }
    
    func getNote(num: Int) -> note{
        return noteController.getNotePlayed(num: num)
    }
    
    func changeNote(){
        sortClefAndNote(clefHolder: clef, noteHolder: note, note: getNote(num: currentNoteNumber))
    }
    
    func sortClefAndNote(clefHolder: clefHolder, noteHolder: NoteHolder, note: note){
        clefHolder.displayClef(clef: note.clef)
        noteHolder.display(note: note)
    }
    
    func setHighScore(){
        data.set(bestEver, forKey: Keys.bestHeldNoteTime)
    }
    
    override func update(_ currentTime: TimeInterval) {
        checkAndDisplay(currentTime: currentTime)
    }
    
    func checkAndDisplay(currentTime: TimeInterval){
        if noteChecker.checkNote(noteToCheck: currentNoteNumber){
            thumbsUp.isHidden = false
            let timeElapsed: TimeInterval = currentTime - startTime
            var colourChangeAmount = timeElapsed/timeToGreen
            if colourChangeAmount > 1{
                colourChangeAmount = 1.0
            }
            self.backgroundColor = UIColor.interpolate(from: .white, to: .green, with: CGFloat(colourChangeAmount))
            if timeElapsed >= 0.5{
                viewController.currentTimeLabel.text = String(format:"%02.02f", timeElapsed)
                if timeElapsed > bestTime{
                    bestTime = timeElapsed
                    setLabels()
                }
                if timeElapsed > bestEver{
                    bestEver = timeElapsed
                    setHighScore() // Find a better solution to this?
                    setLabels()
                }
            }
        }else{
            thumbsUp.isHidden = true
            startTime = currentTime
            viewController.currentTimeLabel.text = "00.00"
            self.backgroundColor = .white
        }
        //viewController.higherLabel.isHidden = true
        //viewController.lowerLabel.isHidden = true
        tooLowText.isHidden = true
        tooHighText.isHidden = true
        
        if noteChecker.getCurrentNote() < currentNoteNumber && noteChecker.getCurrentNote() != -100{
            tooLowText.isHidden = false
            //viewController.higherLabel.isHidden = false
        }else if noteChecker.getCurrentNote() > currentNoteNumber{
            tooHighText.isHidden = false
            //viewController.lowerLabel.isHidden = false
        }
    }
    
    deinit {
        setHighScore()
    }
}
