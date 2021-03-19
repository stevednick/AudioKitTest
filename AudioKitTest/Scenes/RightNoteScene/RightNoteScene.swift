//
//  RightNoteScene.swift
//  Farkas
//
//  Created by Stephen Nicholls on 27/01/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

// Do we turn all these scenes into a class with all the useful shit in them?
// Read that book and rebuild? 

import Foundation
import SpriteKit
import GameplayKit
import UIKit

class RightNoteScene: SKScene { // Sort out how data is dealt with in this scene.
    let noteController = NoteController()
    let noteChecker = NoteChecker()
    let data = Data()
    let timerData = UserDefaults.standard // This needs changing to be consistant.
    let stave = staveHolder()
    let note = NoteHolder()
    let clef = clefHolder()
    let currentPlayedNote = NoteHolder()
    let currentPlayedClef = clefHolder()
    var currentNote = -1000
    var previousNote = -1000
    var heldNoteTime: TimeInterval = 0
    var requiredHeldNoteTime : TimeInterval = 0.5
    var upperLimit = 21
    var lowerLimit = -15
    var score = 0
    var running = false
    var timer : Timer?
    var gameRunTime = 60
    var currentSeconds = 0
    var startingUp = false
    var startCountdown = 3
    var shakeCooldown = 0
    var currentClef = ""
    var showCurrentNote = false
    let stopOdds = [0, 2, 5, 10] // Take this out and put it in tools. 
    
    let ball = BouncyBall()  // Get the ball to appear when the game starts and dissappear when finished.
    var ballOn = false
    
    var tuningPrecision = 0.2
    var feedbackLabel = SKLabelNode(text: "")
    
    weak var viewController: RightNoteViewController!
    
    override func didMove(to view: SKView) {
        data.loadData()
        upperLimit = data.topNote
        lowerLimit = data.bottomNote
        self.backgroundColor = .white
        addChild(stave)
        sortGameNote()
        gameRunTime = 1000  //timerData.integer(forKey: "runSeconds")
        changeNote()
        ball.position = CGPoint(x: 20, y: Data().lineGap * 2 + 12)
        addChild(ball)
        ball.isHidden = true
    
        sortCurrentPlayedNote()
        sortFeedbackLabel()
        
        let tuningLevels = [0.5, 0.38, 0.26, 0.13]
        tuningPrecision = tuningLevels[timerData.integer(forKey: Keys.tuningLevel)]
        
    }
    
    func sortFeedbackLabel(){
        feedbackLabel.setUp(size: 46)
        //feedbackLabel.isHidden = !timerData.bool(forKey: Keys.feedbackOn)
        feedbackLabel.horizontalAlignmentMode = .left
        feedbackLabel.position = CGPoint(x: 80, y: 80)
        feedbackLabel.colorBlendFactor = 1
        addChild(feedbackLabel)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        changeNote()
    }
    
    func startButtonClicked(){
        if running || startingUp{
            endGame(stopped: true)
        }else{
            startGame()
            //viewController.startButton.title = "Stop!"
            //beginStartUp()
        }
    }
    
    func sortGameNote(){
        addChild(note)
        addChild(clef)
        note.position = CGPoint(x: 0, y: 0)
        clef.position = CGPoint(x: -120, y: 0)
        note.isHidden = true
        clef.isHidden = true
    }
    
    func sortCurrentPlayedNote(){
        currentPlayedNote.position = CGPoint(x: 140, y: 0)
        currentPlayedClef.position = CGPoint(x: 50, y: 0)
        currentPlayedNote.alpha = 0.3
        currentPlayedClef.alpha = 0.3
        addChild(currentPlayedClef)
        addChild(currentPlayedNote)
        currentPlayedNote.isHidden = true
        currentPlayedClef.isHidden = true
    }
    
    func beginStartUp(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        startingUp = true
        startCountdown = 3
        viewController.scoreText.text = ""
        viewController.timerText.isHidden = false // Until sorted
        viewController.timerText.text = String(startCountdown)
        // viewController.startButton.title = "Stop!"
    }
    
    func startGame(){
        //viewController.timerText.isHidden = true // Until sorted
        currentSeconds = gameRunTime
        note.isHidden = false
        clef.isHidden = false
        running = true
        score = 0
        displayScore(score: score)
        changeNote()
        ball.isHidden = !viewController.beatSwitch.isOn
    }
    
    func endGame(stopped: Bool){
        note.isHidden = true
        clef.isHidden = true
        running = false
        startingUp = false
        //viewController.startButton.title = "Start!"
        if stopped{
            viewController.timerText.text = ""
        }else{
            viewController.timerText.text = "Finished!"
        }
        timer?.invalidate()
        ball.isHidden = true
    }
    
    func displayPlayedNote(){ // Sort this fucker out.
        let note = noteChecker.currentNote
        if note > -100 && showCurrentNote{
            currentPlayedNote.isHidden = false

            let noteToDisplay = noteController.getNotePlayed(num: note)
            if noteToDisplay.clef != currentClef || !running{
                currentPlayedClef.isHidden = false
            }else{
                currentPlayedClef.isHidden = true
            }
            sortClefAndNote(clefHolder: currentPlayedClef, noteHolder: currentPlayedNote, note: noteToDisplay)
        }else{
            currentPlayedNote.isHidden = true
            currentPlayedClef.isHidden = true
        }
    }
    
    func sortClefAndNote(clefHolder: clefHolder, noteHolder: NoteHolder, note: note){
        clefHolder.displayClef(clef: note.clef)
        noteHolder.display(note: note)
    }
    
    func correctNoteChecker(currentTime: TimeInterval) -> NoteState{
        let current = noteChecker.getCurrentNoteWithDurationandIntonation(currentTime: currentTime)
        if current.duration < 0.1{
            return .wrong
        }
        if current.noteNum > -500{
            if current.noteNum < currentNote{
                if current.noteNum != previousNote{
                    return .tooLow
                }
            }else if current.noteNum > currentNote{
                if current.noteNum != previousNote{
                    return .tooHigh
                }
            }else{
                if current.intonation > tuningPrecision{
                    return .tooSharp
                }else if current.intonation < -tuningPrecision{
                    return .tooFlat
                }else{
                    if current.duration > requiredHeldNoteTime{
                        return .correct
                    }else{
                        return .tooShort
                    }
                }
            }
        }
        return .wrong
    }
    
    override func update(_ currentTime: TimeInterval) {
        if shakeCooldown > 0{
            shakeCooldown -= 1
        }
        if ballOn{
            ball.regularBounce(currentTime: currentTime)
        }
        if running{
            switch correctNoteChecker(currentTime: currentTime){
            case .correct:
                changeNote()
                score += 1
                displayScore(score: score)
                feedbackLabel.text = ""
            case .tooFlat:
                feedbackLabel.text = "Slightly Flat"
                positionLabel(top: false)
                feedbackLabel.fontColor = .orange
            case .tooSharp:
                feedbackLabel.text = "Slightly Sharp"
                positionLabel(top: true)
                feedbackLabel.fontColor = .orange
            case .tooLow:
                feedbackLabel.text = "Too Low"
                positionLabel(top: false, wide: true)
                feedbackLabel.fontColor = .red
            case .tooHigh:
                feedbackLabel.text = "Too High"
                positionLabel(top: true, wide: true)
                feedbackLabel.fontColor = .red
            case .tooShort:
                feedbackLabel.text = "Great!"
                positionLabel(top: true)
                feedbackLabel.fontColor = .green
            default:
                feedbackLabel.text = ""
            }
        }
        if shakeCooldown > 0{
            viewController.shakeCamera(shake: shakeCooldown) // Just for testing
        }
        displayPlayedNote()
        viewController.timerText.text = noteChecker.lis.getAmplitude().forDisplay()

    }
    
    func positionLabel(top: Bool, wide: Bool = false){
        var posY = top ? 80.0 : -100.0
        posY = wide ? posY * 1.25 : posY
        feedbackLabel.position = CGPoint(x: feedbackLabel.position.x, y: CGFloat(posY))
    }
    
    @objc func timerFired(){ // remember to remove shake stuff if necessary!
        if !startingUp && running{
            currentSeconds -= 1
            //displayTime(time: currentSeconds)
            if currentSeconds == 0{
                endGame(stopped: false)
            }
        }else{
            startCountdown -= 1
            if startCountdown <= 0 {
                startingUp = false
                viewController.timerText.text = String("Go!")
                startGame()
                return
                
            }
            viewController.timerText.text = String(startCountdown)
        }
    }
    
    func displayScore(score: Int){
        viewController.updateScoreText(text: "Score: \(score)")
    }
    
    func displayTime(time: Int){
        viewController.updateTimerText(text: time.displayTime())
    }
    
    func changeNote(){
        previousNote = currentNote
        let n = noteController.getRandomNote()
        currentClef = n.clef
        currentNote = n.num
        sortClefAndNote(clefHolder: clef, noteHolder: note, note: n)
        shakeCooldown = 15 // testing
        note.displayStop(stopped: isNoteStopped())
    }
    
    func beatSwitched(){
        ball.isHidden = !ballOn
    }
    
    func isNoteStopped() -> Bool{
         let randomValue = Int.random(in: 1...10)
         if randomValue <= stopOdds[timerData.integer(forKey: Keys.stopLevel)]{
             return true
         }
         return false
     }
    
}

