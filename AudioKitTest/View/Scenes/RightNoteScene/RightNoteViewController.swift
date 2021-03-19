//
//  RightNoteViewController.swift
//  Farkas
//
//  Created by Stephen Nicholls on 27/01/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
class RightNoteViewController: UIViewController { // remember to change view class in .storyboard!
    let cameraNode = SKCameraNode()
    var currentGame: RightNoteScene! // and remember to add .sks file and change it's class too!
    
    @IBOutlet weak var beatSwitch: UISwitch!
    @IBOutlet weak var TitleBar: UINavigationItem!
    @IBOutlet weak var scoreText: UILabel!
    @IBOutlet weak var timerText: UILabel! // now showing amplitude
    @IBOutlet weak var instrumentText: UILabel!
    @IBOutlet weak var amplitudeLabel: UILabel!
    
    var shakeOn = false
    
    let noteStore = UserDefaults.standard
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            
            if let scene = RightNoteScene(fileNamed: "RightNoteScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                currentGame = scene //as? RightNoteScene
                currentGame.viewController = self
                
                //cameraNode.position = CGPoint(x: scene.size.width/2.0, y: scene.size.height/2.0)
                cameraNode.setScale(1.5)
                scene.addChild(cameraNode)
                scene.camera = cameraNode
            }
            view.ignoresSiblingOrder = true
            
            //view.showsFPS = true
            //view.showsNodeCount = true
             
        }
        TitleBar.title = "" // Think of a title.
        scoreText.text = ""
        timerText.text = ""
        amplitudeLabel.isHidden = true
        timerText.isHidden = true
        
        shakeOn = noteStore.bool(forKey: Keys.shakeOn)
        //timerText.isHidden = true // Until we work out how to deal with timer shit. Probably reintroduce...
        let currentInstrument = InstrumentStore().getInstrumentName()
        let currentTransposition = InstrumentStore().getCurrentTranspositionName()
        instrumentText.text = "\(currentInstrument ) in \(currentTransposition )"
        
        UIApplication.shared.isIdleTimerDisabled = true
        currentGame.startGame()

    }
    
    func shakeCamera(shake: Int){
        if shakeOn{
            let yPos = Int.random(in: -shake...shake)
            let xPos = Int.random(in: -shake/2...shake/2)
            cameraNode.position = CGPoint(x: xPos, y: yPos)
        }
    }
    
    @IBAction func beatSwitchSwitched(_ sender: UISwitch) {
        currentGame.ballOn = sender.isOn
        currentGame.beatSwitched()
    }
    
    
    @IBAction func currentSwitchChanged(_ sender: UISwitch) {
        currentGame.showCurrentNote = sender.isOn
        amplitudeLabel.isHidden = !sender.isOn
        timerText.isHidden = !sender.isOn
    }
    
    
    func updateTimerText(text: String){
        timerText.text = text
    }
    
    func updateScoreText(text: String){
        scoreText.text = text
    }
    
    func updateTitleBar(text: String){
        TitleBar.title = text
    }
    
    @IBAction func close(){
        currentGame.endGame(stopped: true)
        dismiss(animated: true, completion: nil)
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
