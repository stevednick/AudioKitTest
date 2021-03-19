//
//  LongNoteViewController.swift
//  Farkas
//
//  Created by Stephen Nicholls on 03/03/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class LongNoteViewController: UIViewController {
    let data = UserDefaults.standard
    var currentScene: LongNoteScene!
    let cameraNode = SKCameraNode()
    @IBOutlet weak var panView: UIView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var bestTodayLabel: UILabel!
    @IBOutlet weak var bestEverLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            // view.showsPhysics = true
            if let scene = LongNoteScene(fileNamed: "LongNoteScene") {
                
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
                currentScene = scene //as? LongNoteScene
                currentScene.viewController = self
                cameraNode.setScale(1.5)
                scene.addChild(cameraNode)
                scene.camera = cameraNode
            }
            view.ignoresSiblingOrder = true
            
            //view.showsFPS = true
            //view.showsNodeCount = true
        }
        currentScene.setLabels()
        setSensitivityLabel()
        UIApplication.shared.isIdleTimerDisabled = true
    }

    @IBAction func close(){
        UIApplication.shared.isIdleTimerDisabled = false
        dismiss(animated: true, completion: nil)
    }
    
    func setSensitivityLabel(){
        currentScene.noteChecker.forgiveness = data.integer(forKey: Keys.forgiveness)
    }

    @IBAction func notePanned(_ sender: UIPanGestureRecognizer) {
        let translationLimit: CGFloat = 20
        let touchLocation = sender.location(in: self.view)
        let translation = sender.translation(in: self.view)
        if panView.frame.contains(touchLocation){
            
            if translation.y > translationLimit{
                currentScene.currentNoteNumber -= 1
                currentScene.changeNote()
                sender.setTranslation(CGPoint.zero, in: self.view)
            }else if translation.y < -translationLimit{
                currentScene.currentNoteNumber += 1
                currentScene.changeNote()
                sender.setTranslation(CGPoint.zero, in: self.view)
            }
        }else{
            sender.setTranslation(CGPoint.zero, in: self.view)
        }
    }
}
