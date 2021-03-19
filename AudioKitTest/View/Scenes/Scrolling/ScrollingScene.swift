//
//  ScrollingScene.swift
//  Farkas
//
//  Created by Stephen Nicholls on 11/02/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import SpriteKit

enum NoteState{
    case waiting
    case wrong
    case correct
    case tooShort
    case tooLow
    case tooHigh
    case tooSharp
    case tooFlat
}

struct ColliderType{
    static let bar: UInt32 = 0x1 << 0
    static let box: UInt32 = 0x1 << 1
}

class ScrollingScene: SKScene, SKPhysicsContactDelegate{ // Sort out cameranode thing.
    
    let data = UserDefaults.standard
    weak var viewController: ScrollingViewController!
    var lastClef = "null"
    let stave = staveHolder()
    //var previousTime: TimeInterval = 0
    var tempo: Double = 60
    
    var barSpeed = 0.0
    let barLength: Double = 400
    var newBarStart: TimeInterval = 0
    var bars = [BarHolder]()
    var box = SKShapeNode()
    
    var currentNote = -1000
    var currentNoteState = NoteState.waiting

    var currentBar: BarHolder? = nil
    
    var heldNoteTime: TimeInterval = 0
    var requiredHeldNoteTime : TimeInterval = 0.3 // This should change based on tempo
    var previousNoteCheckerTime : TimeInterval = 100000
    var noteActive = false
    let tick = TickHolder()
    var shakeCooldown = 0
    
    // var currentBeat = 1
    let ballOffset:CGFloat = 50
    let beat = BouncyBall()
    
    var firstTimeRound = true
    var listening = false
    var gameDuration = 120
    var countDownStarted = false
    var gameMode: Game = Game.standard
    var beatDuration = 0.0
    var finished = false

    // Scoring
    
    var score = 0.0
    var difficultyMultiplier = 1.0
    var rangeMultiplier = 1.0
    var notesSeen = 0
    var notesCorrect = 0
    var streak = 0
    var bestStreak = 0
    let stopOdds = [0, 2, 5, 10]
    
    var missedNotes: [note] = [note]()
    let missedNoteReturnProbability = 5
    
    let noteContoller = NoteController()
    var currentRangeModifier = 0.0
    var currentMaxPriority = 0
    
    let noteChecker = NoteChecker()
    
    let highScoreKeys: [Game: String] = [.standard: Keys.endlessHighScore, .challenge: Keys.highScore, .blitz: Keys.blitzHighScore]
    var tuningPrecision = 0.2
    var feedbackLabel = SKLabelNode(text: "")
    
    var pauseState = false
    var pauseStarted = false
    var pauseStartTime: TimeInterval = 0.0
    var clockCounter = 0
    var beatRemainingTime: TimeInterval = 0.0
    var lastUpdate: TimeInterval = 0.0
    
    // Blitz mode: Sort High score/ time display/ Score display etc...
    
    
    override func didMove(to view: SKView) {
        addChild(stave)
        setTempo(t: Double(data.integer(forKey: "bPM"))) // Get Keys for these.
        if gameDuration == 0 {
            gameDuration = 120
        }
        physicsWorld.contactDelegate = self
        addBox()
        addStartBox()
        tick.position = CGPoint(x: 100, y: 150)
        addChild(tick)
        beat.position = CGPoint(x: -ballOffset, y: Data().lineGap * 2 + 12)
        addChild(beat)
        difficultyMultiplier = calculateSwitchMultiplier()
        rangeMultiplier = calculateRangeMultiplier()
        
        let tuningLevels = [0.5, 0.38, 0.26, 0.13]
        tuningPrecision = tuningLevels[data.integer(forKey: Keys.tuningLevel)]
        sortFeedbackLabel()
    }
    
    func pause(startPause: Bool, quickUnpause: Bool = false){
        func resumeBeat(){
            if beatRemainingTime <= beatDuration * 3{
                beat.run(SKAction.move(to: CGPoint(x: -ballOffset, y: Data().lineGap * 2 + 12), duration: beatRemainingTime))
            }else{
                let sequence = [
                    SKAction.move(to: CGPoint(x: 0, y: Data().lineGap * 2 + 12), duration: beatRemainingTime - (beatDuration * 3)),
                    SKAction.move(to: CGPoint(x: -ballOffset, y: Data().lineGap * 2 + 12), duration: beatDuration * 3)
                ]
                beat.run(SKAction.sequence(sequence))
            }
            startGame(resuming: true)
            viewController.finishUnpause()
            beat.pause(startPause: startPause)
            pauseState = startPause
        }
        
        func resumeBars(){
            for bar in bars{
                let moveAction = SKAction.move(by: CGVector(dx: -barSpeed * 100, dy: 0), duration: 100)
                bar.run(moveAction, withKey: "moving")
            }
        }
        
        if quickUnpause{
            resumeBeat()
            resumeBars()
            return
        }

        if startPause{
            pauseState = startPause
            beat.pause(startPause: startPause)
            removeAction(forKey: "clockCounter")
            beat.removeAllActions()
            for bar in bars{
                bar.removeAction(forKey: "moving")
            }
        }else{
            viewController.activatePauseButton(on: false)
            var countDownValue = 3
            let displayNote = SKAction.run {
                self.viewController.countDownLabel.text = String(countDownValue);
                countDownValue -= 1
            }
            let displayNothing = SKAction.run{
                self.viewController.countDownLabel.text = ""
                self.viewController.activatePauseButton(on: true)
                resumeBars()
                resumeBeat()
            }
            let waitAction = SKAction.wait(forDuration: 0.75)
            let sequence = SKAction.sequence([displayNote, waitAction, displayNote, waitAction, displayNote, waitAction, displayNothing])
            run(sequence, withKey: "resumeSequence")
        }

    }
    
    func sortFeedbackLabel(){
        feedbackLabel.setUp(size: 36)
        feedbackLabel.isHidden = true
        feedbackLabel.horizontalAlignmentMode = .left
        feedbackLabel.position = CGPoint(x: 170, y: 140)
        addChild(feedbackLabel)
    }
    
    func setTempo(t: Double){
        tempo = t
        barSpeed = (barLength * tempo) / 240
        beatDuration = 60/tempo
        beat.changeTempo(newTempo: t)
        setRequiredNoteDuration(duration: beatDuration)
    }
    
    func isNoteStopped() -> Bool{
        let randomValue = Int.random(in: 1...10)
        if randomValue <= stopOdds[data.integer(forKey: Keys.stopLevel)]{
            return true
        }
        return false
    }
    
    func setRequiredNoteDuration(duration: TimeInterval){ // Test and decide on appropriate note length.
        requiredHeldNoteTime = duration / 2.0
    }
    
    func setMode(mode: Game){
        gameMode = mode
        switch mode{
        case .standard:
            listening = true
            gameDuration = data.integer(forKey: "runSeconds")
        case .challenge:
            listening = true
            setTempo(t: 72)
            gameDuration = 120
        case .listeningOff:
            listening = false
            viewController.finishButton.isHidden = true
            viewController.finishButton.isEnabled = false
            gameDuration = data.integer(forKey: "runSeconds")
        case .blitz:
            viewController.timerLabel.isHidden = true
            viewController.scoreLabel.isHidden = true
            listening = true
            setTempo(t: 72)
            gameDuration = 1000 // Block out Timer and display note.
        default:
            return
        }
    }
    
    func addBox(){
        let leftLimit = -150
        let boxWidth = 300
        let height = 100
        box = SKShapeNode(rect: CGRect(x: leftLimit, y: -height, width: boxWidth, height: height*2))
        box.lineWidth = 2
        box.strokeColor = .clear
        box.name = "box"
        box.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: boxWidth, height: height*2),
            center: CGPoint(x: leftLimit + boxWidth/2 , y: 0))
        box.physicsBody!.affectedByGravity = false
        box.physicsBody!.isDynamic = false
        box.physicsBody!.categoryBitMask = ColliderType.box
        addChild(box)
    }
    
    func addStartBox(){
        let height = 100
        box = SKShapeNode(rect: CGRect(x: 380, y: -height, width: 20, height: height*2))
        box.lineWidth = 2
        box.strokeColor = .clear
        box.name = "startBox"
        box.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: 800, height: height*2))
        box.physicsBody!.affectedByGravity = false
        box.physicsBody!.isDynamic = false
        box.physicsBody!.categoryBitMask = ColliderType.box
        addChild(box)
    }
    
    func addBar(){
        var manualNote: note = note(pos: -1000, accidental: "null", clef: "treble", priority: 0, num: 0)
        if missedNotes.count > 0 && Int.random(in: 0...missedNoteReturnProbability) == missedNoteReturnProbability{
            let notePos = Int.random(in: 0..<missedNotes.count)
            manualNote = missedNotes.remove(at: notePos)
            manualNote.flashing = true
        }
        
        if gameMode == .blitz{
            manualNote = noteContoller.getRandomNoteWithRestrictions(maxPriority: currentMaxPriority, rangeReduction: currentRangeModifier)
        }
        
        let newBar = BarHolder(last: lastClef, manualNote)
        newBar.name = "bar"
        newBar.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 20))
        newBar.physicsBody!.affectedByGravity = false
        newBar.physicsBody!.isDynamic = true
        newBar.physicsBody!.categoryBitMask = ColliderType.bar
        newBar.physicsBody?.collisionBitMask = 0
        newBar.physicsBody!.contactTestBitMask = ColliderType.box
        
        lastClef = newBar.currentClef
        newBar.position = CGPoint(x: 900, y: 0)
        let moveAction = SKAction.move(by: CGVector(dx: -barSpeed * 100, dy: 0), duration: 100)
        
        newBar.run(moveAction, withKey: "moving")

        addChild(newBar)
        bars.append(newBar)
        if isNoteStopped(){
            newBar.stoppedNote()
        }
    }
    
    func startCountdown(){
        var countDownValue = 4
        let displayNote = SKAction.run {
            self.viewController.countDownLabel.text = String(countDownValue);
            countDownValue -= 1
        }
        let displayGo = SKAction.run{
            self.viewController.countDownLabel.textColor = .green
            self.viewController.countDownLabel.text = "Go!"
            self.startGame()
        }
        let displayNothing = SKAction.run{
            self.viewController.countDownLabel.text = ""
            self.viewController.activatePauseButton(on: true)
        }
        let waitAction = SKAction.wait(forDuration: beatDuration)
        let actions = [displayNote, waitAction, displayNote, waitAction, displayNote, waitAction, displayNote, waitAction, displayGo, SKAction.wait(forDuration: 3), displayNothing]
        let countDownSequence = SKAction.sequence(actions)
        run(countDownSequence, withKey: "countdown")
    }
    
    func startGame(resuming: Bool = false){
        if !resuming{
            self.clockCounter = self.gameDuration
        }
        let clockWaitAction = SKAction.wait(forDuration: 1)
        let displayAction = SKAction.run {

            self.displayTime(clockCounter: self.clockCounter)
            self.clockCounter -= 1
        }
        let actionSequence = SKAction.sequence([displayAction, clockWaitAction])
        let countDownSequence = SKAction.repeat(actionSequence, count: self.gameDuration + 1)
        let finish = SKAction.run {
            self.viewController.timerLabel.text = "Finished"
            self.finished = true
        }
        let scoreBoardAction = SKAction.run {
            if self.gameMode != .listeningOff{
                self.showScoreboard()
            }
        }
        let fullSequence = SKAction.sequence([countDownSequence, finish, SKAction.wait(forDuration: 2), scoreBoardAction])
        run(fullSequence, withKey: "clockCounter")
    }
    
    func restart(){
        viewController.showFinishScreen(reset: true)
        for bar in bars{
            bar.removeFromParent()
        }
        currentNote = -1000
        currentNoteState = NoteState.waiting
        noteActive = false
        currentBar = nil
        missedNotes = []
        lastClef = "null"
        pauseState = false
        pauseStarted = false
        bars = []
        newBarStart = 0.0
        finished = false
        setMode(mode: gameMode)
        displayTime(clockCounter: gameDuration)
        score = 0
        notesSeen = 0
        notesCorrect = 0
        streak = 0
        bestStreak = 0
        beat.resetBeat()
        viewController.activatePauseButton(on: false)
        countDownStarted = false
        viewController.pauseButton.setTitle("Pause", for: .normal)
        viewController.countDownLabel.text = ""
        removeAction(forKey: "clockCounter")
        removeAction(forKey: "countdown")
        removeAction(forKey: "resumeSequence") // try removeAllActions? at top!
    }
    
    func displayTime(clockCounter: Int){
        viewController.timerLabel.text = "Time: " + clockCounter.displayTime()
    }
    
    func checkBarsFinished(currentTime: TimeInterval){
        for bar in bars{
            if bar.position.x < -1500{
                bar.removeFromParent()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "box"{
            let bar = contact.bodyB.node as! BarHolder
            noteEntered(bar: bar)
        }else if contact.bodyB.node?.name == "box"{
            let bar = contact.bodyA.node as! BarHolder
            noteEntered(bar: bar)
        }
        if contact.bodyA.node?.name == "startBox" || contact.bodyB.node?.name == "startBox"{
            if !countDownStarted{
                startCountdown()
                countDownStarted = true
            }
        }
    }
    
    func noteEntered(bar: BarHolder){
        currentNote = bar.noteShowing.num
        changeNoteState(newState: .wrong)
        currentBar = bar
        noteActive = true
        beat.nextJumpHeight = Double(bar.noteTop)
        if !finished{
             notesSeen += 1 // should we move this? Log these once the note leaves the box or it's played?
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        func barLeft(bar: BarHolder){
            func wrongNote(){
                streak = 0
                updateLabels()
                shakeCooldown = 25
                tick.display(isCorrect: false)
                missedNotes.append(bar.getCurrentNote())
                if gameMode == .blitz{
                    showScoreboard()
                }
            }
            if noteActive && listening && !finished{
                switch currentNoteState {
                case .wrong:
                    wrongNote()
                case .correct:
                    currentBar?.dissapearNote()
                    score += calculateStreakMultiplier(streak: streak)
                    streak += 1
                    notesCorrect += 1
                    checkStreak()
                    noteActive = false
                    updateLabels()
                    shakeCooldown = 6
                    tick.display(isCorrect: true)
                case .tooShort:
                    showFeedbackLabel(text: "Play Longer!")
                case .tooSharp:
                    showFeedbackLabel(text: "Slightly Sharp!")
                case .tooFlat:
                    showFeedbackLabel(text: "Slightly Flat!")
                case .tooHigh:
                    wrongNote()
                    showFeedbackLabel(text: "Too High!")
                case .tooLow:
                    wrongNote()
                    showFeedbackLabel(text: "Too Low!")
                default:
                    print("Something has gone wrong in currentNoteState Switch Case")
                }
            }
            currentNote = -1000
            noteActive = false
            changeNoteState(newState: .waiting)
        }
        if contact.bodyA.node?.name == "box"{
            let bar = contact.bodyB.node as! BarHolder
            barLeft(bar: bar)
        }else if contact.bodyB.node?.name == "box"{
            let bar = contact.bodyA.node as! BarHolder
            barLeft(bar: bar)
        }
    }
    
    func showFeedbackLabel(text: String){
        if data.bool(forKey: Keys.feedbackOn){
            feedbackLabel.text = text
            //viewController.feedbackLabel.text = text
            let showText = SKAction.run {
                self.feedbackLabel.isHidden = false
                //self.viewController.feedbackLabel.isHidden = false
            }
            let waitAction = SKAction.wait(forDuration: 1.0)
            let hideText = SKAction.run {
                self.feedbackLabel.isHidden = true
                //self.viewController.feedbackLabel.isHidden = true
            }
            let actionSequence = SKAction.sequence([showText, waitAction, hideText])
            if viewController.countDownLabel.text == ""{
                run(actionSequence)
            }
        }
    }
    
    func increaseTempo(){
        tempo += 2
        setTempo(t: tempo)
        for bar in bars{
            bar.removeAction(forKey: "moving")
            let moveAction = SKAction.move(by: CGVector(dx: -barSpeed * 100, dy: 0), duration: 100)
            bar.run(moveAction, withKey: "moving")
        }
    }
    
    func increaseDifficulty(){
        let barsToMax = 50.0
        increaseTempo()
        currentRangeModifier = Double(notesSeen) / barsToMax
        if notesSeen > 40{
            currentMaxPriority = 2
        }else if notesSeen > 20{
            currentMaxPriority = 1
        }
    }

    override func update(_ currentTime: TimeInterval) {
        
        if pauseState && !pauseStarted{
            pauseStartTime = currentTime
            beatRemainingTime = newBarStart - currentTime
            print(beatRemainingTime/beatDuration)
            pauseStarted = true
        }
        if !pauseState && pauseStarted{
            newBarStart += currentTime - pauseStartTime
            pauseStarted = false
        }
        if !pauseStarted{
            checkBarsFinished(currentTime: currentTime) // For removal of bars when off screen.
            if currentTime >= newBarStart{
                if gameMode == .blitz{
                    increaseDifficulty()
                }
                offsetBeat() // See if this works here
                addBar()
                let barDuration = (60/tempo) * 4
                if firstTimeRound || currentTime >= newBarStart + 1{
                    updateLabels()
                    newBarStart = currentTime + barDuration
                    firstTimeRound = false
                }else{
                    newBarStart = newBarStart + barDuration
                }
            }
            if listening && !finished{
                correctNoteChecker(currentTime: currentTime)
                sortShake()
            }
        }
        beat.regularBounce(currentTime: currentTime)
        lastUpdate = currentTime
    }
    
    func checkStreak(){
        if streak > bestStreak{
            bestStreak = streak
        }
    }
    
    func sortShake(){
        if shakeCooldown > 0{
            shakeCooldown -= 1
        }
        if shakeCooldown > 0{
            viewController.shakeCamera(shake: shakeCooldown * 2) // Just for testing
        }
    }
    
    func updateLabels(){ // Turn these off for not listening...
        if !listening{
            viewController.displayScore(score: -1.0)
            viewController.displayStreak(streak: -1)
            
        }else{
            viewController.displayScore(score: score)
            viewController.displayStreak(streak: streak)
        }
    }
    
    func correctNoteChecker(interval: TimeInterval) -> Bool{
        if noteChecker.checkNote(noteToCheck: currentNote){
            heldNoteTime += interval
            if heldNoteTime >= requiredHeldNoteTime{
                return true
            }
        }else{
            heldNoteTime = 0
        }
        return false
    }
    
    func correctNoteChecker(currentTime: TimeInterval){
        if currentNoteState == .correct{
            return
        }
        let noteToCheck = noteChecker.getCurrentNoteWithDurationandIntonation(currentTime: currentTime)
        if noteToCheck.noteNum == currentNote{
            if noteToCheck.duration >= requiredHeldNoteTime{
                if noteToCheck.intonation >= tuningPrecision{
                    changeNoteState(newState: .tooSharp)
                }else if noteToCheck.intonation <= -tuningPrecision{
                    changeNoteState(newState: .tooFlat)
                }else{
                    changeNoteState(newState: .correct)
                }
            }else if noteToCheck.duration >= requiredHeldNoteTime/2.0{
                changeNoteState(newState: .tooShort)
            }
        }else if noteToCheck.duration >= requiredHeldNoteTime{
            if noteToCheck.noteNum > currentNote{
                changeNoteState(newState: .tooHigh)
            }else if noteToCheck.noteNum > -100{
                changeNoteState(newState: .tooLow)
            }
        }
    }
    
    func changeNoteState(newState: NoteState){
        if newState == .waiting{
            currentNoteState = .waiting
        }
        if newState != .wrong && currentNoteState == .waiting{
            return
        }
        
        
        if currentNoteState == .correct{
            return
        }
        switch newState {
        case .correct:
            currentNoteState = .correct
        case .tooShort:
            currentNoteState = .tooShort
        case .tooHigh:
            currentNoteState = .tooHigh
        case .tooLow:
            currentNoteState = .tooLow
        case .waiting:
            currentNoteState = .waiting
        case .wrong:
            currentNoteState = .wrong
        case .tooSharp:
            currentNoteState = .tooSharp
        case .tooFlat:
            currentNoteState = .tooFlat
        }
    }
    
    func offsetBeat(){
        beat.position = CGPoint(x: -ballOffset, y: Data().lineGap * 2 + 12)
        let moveLeft = SKAction.move(by: CGVector(dx: -ballOffset, dy: 0), duration: beatDuration * 3)
        let moveRight = SKAction.move(by: CGVector(dx: ballOffset, dy: 0), duration: beatDuration)
        let moveSequence = SKAction.sequence([moveRight, moveLeft])
        beat.run(moveSequence, withKey: "beatOffset")
    }
    
    func calculateStreakMultiplier(streak: Int) -> Double{
        let streakDelay = 3.0
        let streakMultiplier = 0.1
        let multiplierLevel = round(Double(streak)/streakDelay)
        return 1.0 + (multiplierLevel * streakMultiplier)
    }
    
    func calculateSwitchMultiplier() -> Double{
        if gameMode == .blitz{
            return 1.0
        }
        let totalSwitches = 35.0
        let switchesOn = Double(NoteController().getNumberOfSwitches())
        let addedScore = switchesOn/totalSwitches
        let tuningBonus = Double(data.integer(forKey: Keys.tuningLevel)) * 0.15
        return 0.5 + addedScore + tuningBonus
    }
    
    func calculateRangeMultiplier() -> Double{ // tidy these
        let range = Double(NoteController().getTotalRange())
        let oneValue = 48.0
        return 0.5 + range/oneValue
    }
    
    func showScoreboard(){  // Modify this to be more flexible.
        if viewController.pauseState{
            pause(startPause: false, quickUnpause: true)
        }
        viewController.activatePauseButton(on: true)
        viewController.pauseButton.setTitle("Restart", for: .normal)
        func showNewHighScore(){
            viewController.newHighScore.isHidden = false
            viewController.newHighScore.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 6)
        }
        if gameMode == .blitz{
            if checkBlitzHighScore(){
                showNewHighScore()
            }else{
                viewController.newHighScore.isHidden = true
            }
            for label in viewController.finishScreenLabels{
                label.isHidden = true
            }
            viewController.totalLabel.text = "\(notesCorrect) Notes"
            viewController.highScoreLabel.text = "\(data.integer(forKey: Keys.blitzNotes)) Notes"
            viewController.showFinishScreen()
            return
        }
        let newHighScore = checkHighScore()

        viewController.highScoreLabel.text = data.double(forKey: highScoreKeys[gameMode] ?? Keys.highScore).forDisplay()
        if newHighScore{
            showNewHighScore()
        }else{
            viewController.newHighScore.isHidden = true
        }
        viewController.difficultyLabel.text = "x" + calculateSwitchMultiplier().forDisplay()
        viewController.rangeLabel.text = "x" + calculateRangeMultiplier().forDisplay()
        viewController.seenLabel.text = "\(notesSeen)"
        viewController.correctLabel.text = "\(notesCorrect)"
        viewController.finalScoreLabel.text = score.forDisplay()
        let totalScore = score * calculateRangeMultiplier() * calculateSwitchMultiplier()
        viewController.totalLabel.text = totalScore.forDisplay()
        viewController.bestStreakLabel.text = "\(bestStreak)"
        viewController.showFinishScreen()
    }
    
    func checkBlitzHighScore() -> Bool{
        if notesCorrect > data.integer(forKey: Keys.blitzNotes){
            data.set(notesCorrect, forKey: Keys.blitzNotes)
            return true
        }
        return false
    }
    
    func checkHighScore() -> Bool{
        let totalScore = score * calculateRangeMultiplier() * calculateSwitchMultiplier()
        if totalScore > data.double(forKey: highScoreKeys[gameMode] ?? Keys.highScore){
            data.set(totalScore, forKey: highScoreKeys[gameMode] ?? "emergency")
            return true
        }
        return false
    }
}
