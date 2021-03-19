//
//  ScrollingViewController.swift
//  Farkas
//
//  Created by Stephen Nicholls on 11/02/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class ScrollingViewController: UIViewController{
    
    var currentScene: ScrollingScene!
    let cameraNode = SKCameraNode()
    var shakeOn = false
    
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    // Finished Pane
    
    @IBOutlet weak var seenLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var bestStreakLabel: UILabel!
    @IBOutlet weak var finalScoreLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var finishedView: UIView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var newHighScore: UILabel!
    @IBOutlet weak var instrumentLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var pausedLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet var finishScreenLabels: [UILabel]!
    
    let data = UserDefaults.standard
    var minutes = 0
    var seconds = 0
    var mode = Game.standard
    
    var pauseState = false
    var dimmingView: UIView!
    var pausedText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            // view.showsPhysics = true
            if let scene = ScrollingScene(fileNamed: "ScrollingScene") {
                
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
                currentScene = scene// as? ScrollingScene
                currentScene.viewController = self
                
                //cameraNode.position = CGPoint(x: scene.size.width/2.0, y: scene.size.height/2.0)
                cameraNode.setScale(1.5)
                scene.addChild(cameraNode)
                scene.camera = cameraNode
                currentScene.setMode(mode: mode) // sets listening or endless mode etc
            }
            view.ignoresSiblingOrder = true
            
            //view.showsFPS = true
            //view.showsNodeCount = true
            displayScore(score: 0.0)
            displayStreak(streak: 0)
        }
        
        countDownLabel.text = ""
        feedbackLabel.isHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
        sortInstrumenLabel()
        currentScene.displayTime(clockCounter: currentScene.gameDuration)
        shakeOn = data.bool(forKey: Keys.shakeOn)
        NotificationCenter.default.addObserver(self, selector: #selector(onEnteredBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func onEnteredBackground(){
        pauseState = true
        pause(pauseOn: true)
        currentScene.update(currentScene.lastUpdate)
        activatePauseButton(on: true)
    }
    
    func pause(pauseOn: Bool){
        currentScene.pause(startPause: pauseOn)
        if pauseOn{
            pauseButton.setTitle("Resume!", for: .normal)
            dimmingView = UIView(frame: CGRect(x: -2000, y: -2000, width: 4000, height: 4000))
            dimmingView.backgroundColor = .black
            dimmingView.alpha = 0.2
            dimmingView.frame = view.bounds
            dimmingView.isUserInteractionEnabled = false
            self.view.addSubview(dimmingView)
            pausedLabel.isHidden = false
            //dimmingView.addSubview(pausedLabel)
            //pauseButton.titleLabel?.text = "Unpause!"
        }
    }
    
    func finishUnpause(){
        pauseButton.setTitle("Pause", for: .normal)
        dimmingView.removeFromSuperview()
        pausedLabel.isHidden = true
        //pauseButton.titleLabel?.text = "Pause"
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        if finishedView.isHidden{
            pauseState = !pauseState
            pause(pauseOn: pauseState)
        }else{
            currentScene.restart()
        }
        
    }
    
    func activatePauseButton(on: Bool){
        pauseButton.isHidden = !on
        pauseButton.isUserInteractionEnabled = on
    }
    
    
    func sortInstrumenLabel(){
        pausedLabel.isHidden = true
        activatePauseButton(on: false)
        let currentInstrument = InstrumentStore().getInstrumentName()
        let currentTransposition = InstrumentStore().getCurrentTranspositionName()
        instrumentLabel.text = "\(currentInstrument ) in \(currentTransposition )"
    }
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        currentScene.showScoreboard()
    }
    
    func showFinishScreen(reset: Bool = false){
        finishedView.isHidden = reset
        currentScene.listening = false // sort in game mode
        finishButton.isHidden = !reset
        finishButton.isEnabled = reset
    }

    
    @IBAction func close(){
        if mode != .listeningOff && finishedView.isHidden{
            currentScene.showScoreboard()
        }else{
            dismiss(animated: true, completion: nil)
        }
    }
    
    func displayScore(score: Double){
        if score >= 0{
            scoreLabel.text = "Score: " + score.forDisplay()
        }else{
            scoreLabel.text = ""
        }
    }
    
    func displayStreak(streak: Int){
        if streak >= 0{
            streakLabel.text = "Streak: \(streak)"
        }else{
            streakLabel.text = ""
        }
    }
    
    func shakeCamera(shake: Int){ // can this be moved off piste?
        if shakeOn{
            let yPos = Int.random(in: -shake...shake)
            let xPos = Int.random(in: -shake/2...shake/2)
            cameraNode.position = CGPoint(x: xPos, y: yPos)
        }
    }
 
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
