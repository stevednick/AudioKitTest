//
//  FrontPageViewController.swift
//  Farkas
//
//  Created by Stephen Nicholls on 27/01/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import UIKit
import SpriteKit
import AVKit

protocol LoadedViewControllerDelegate: class{
    func reloadScreen()
}

protocol FrontPagePickerViewControllerDelegate: class{
    func displayTime()
    func displayBPM()
}

class FrontPageViewController: UIViewController, LoadedViewControllerDelegate, FrontPagePickerViewControllerDelegate {
    
    let transition = SlideInTransition()

    var noteController = NoteController()
    let data = UserDefaults.standard
    var currentScene: FrontPageScene!
    let screenScale: CGFloat = 1.5
    var topNoteRect: CGRect = CGRect()
    var bottomNoteRect: CGRect = CGRect()
    var mode: Game = .standard

    @IBOutlet weak var DurationButton: UIButton!
    @IBOutlet weak var bpmButton: UIButton!
    //@IBOutlet weak var modeChooser: UISegmentedControl!
    @IBOutlet weak var instrumentLabel: UILabel!
    //@IBOutlet weak var endlessHSLabel: UILabel!
    //@IBOutlet weak var challengeHSLabel: UILabel!
    @IBOutlet weak var stoppedChooser: UISegmentedControl!
    @IBOutlet weak var stoppingLabel: UILabel!
    
    var minutes = 0
    var seconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            
            if let scene = FrontPageScene(fileNamed: "FrontPageScene") {
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
                currentScene = scene //as? FrontPageScene
                currentScene.viewController = self
                let cameraNode = SKCameraNode()
                cameraNode.setScale(screenScale)
                scene.addChild(cameraNode)
                scene.camera = cameraNode
            }
            view.ignoresSiblingOrder = true
            
            //view.showsFPS = true
            //view.showsNodeCount = true
        }
        firstStartCheck()
        displayTime()
        displayBPM()
        //modeChooser.selectedSegmentIndex = 0
        sortInstrumenLabel()
        sortNoteRects()
    }
    
    func firstStartCheck(){
        if !data.bool(forKey: Keys.firstStartComplete){
            data.set(60, forKey: "bPM")
            data.set(120, forKey: "runSeconds")
            data.set(true, forKey: Keys.feedbackOn)
            data.set(true, forKey: Keys.shakeOn)
            data.set(2, forKey: Keys.tuningLevel)
            data.set(3, forKey: Keys.forgiveness)
            data.set(440, forKey: Keys.concertA)
            data.set(0, forKey: Keys.stopLevel)
            data.set(true, forKey: Keys.firstStartComplete)
            print("Settings Set")
        }
    }
    
    @IBAction func startButtonPressed(_ sender: UIBarButtonItem) {
        
        guard let menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as? FrontPageMenuViewController else {
            return}
        menuViewController.didTapMenuType = { game in
            self.startGame(m: game)
        }
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        present(menuViewController, animated: true, completion: nil)
    }
    
    func startGame(m: Game){
        if m == Game.longNote{
            performSegue(withIdentifier: "toLongNote", sender: self)
            checkMicAccess()
        }else if m == Game.fixed{
            performSegue(withIdentifier: "toRightNote", sender: self)
            checkMicAccess()
        }else{
            if m != Game.listeningOff {
                checkMicAccess()
            }
            self.mode = m
            performSegue(withIdentifier: "toScrolling", sender: self)
        }
    }
    
    func reloadScreen(){
        currentScene.displayNotes()
        sortInstrumenLabel()
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        sortNoteRects()
    }
    
    func sortNoteRects(){
        let screenSize = UIScreen.main.bounds
        var (topNoteXPos, bottomNoteXPos) = currentScene.getNotePositions()
        topNoteXPos = sortXPos(pos: topNoteXPos)
        bottomNoteXPos = sortXPos(pos: bottomNoteXPos)
        let gap:CGFloat = bottomNoteXPos - topNoteXPos
        topNoteRect = CGRect(x: topNoteXPos - gap/2, y: screenSize.height/2 - 500, width: gap, height: 1000)
        bottomNoteRect = CGRect(x: bottomNoteXPos - gap/2 , y: screenSize.height/2 - 500, width: gap, height: 1000)
    }
    
    func sortXPos(pos: CGFloat) -> CGFloat{
        let screenSize = UIScreen.main.bounds
        var newPos = pos
        newPos /= screenScale
        newPos *= screenSize.maxX/2
        newPos += screenSize.maxX/2
        return newPos
    }
    
    func positionRangeText(){
        if currentScene.topNotePos < 10{
            currentScene.rangeText.position = CGPoint(x: 95, y: 145)
        }else{
            currentScene.rangeText.position = CGPoint(x: 95, y: -130)
        }
    }
    
    func sortInstrumenLabel(){
        let currentInstrument = InstrumentStore().getInstrumentName()
        let currentTransposition = InstrumentStore().getCurrentTranspositionName()
        instrumentLabel.text = "\(currentInstrument ) in \(currentTransposition )"
        stoppedChooser.selectedSegmentIndex = data.integer(forKey: Keys.stopLevel)
        stoppedChooser.isHidden = currentInstrument != "Horn"
        stoppedChooser.isEnabled = currentInstrument == "Horn"
        stoppingLabel.isHidden = currentInstrument != "Horn"
        if currentInstrument != "Horn"{
            data.set(0, forKey: Keys.stopLevel)
        }
        positionRangeText()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is FrontPagePickerViewController
        {
            let vc = segue.destination as? FrontPagePickerViewController
            vc?.delegate = self
            if segue.identifier != "DurationButton"{
                vc?.bpmPicker = true
            }
        }
        if segue.destination is ScrollingViewController
        {
            let vc = segue.destination as? ScrollingViewController
            vc?.mode = mode
        }
        if segue.destination is OptionsViewController{
            let vc = segue.destination as? OptionsViewController
            vc?.delegate = self
        }
        
    }
 
    
    func displayBPM(){
        var bpm = data.integer(forKey: "bPM")
        if bpm < 30{
            bpm = 60
            data.set(60, forKey: "bPM")
        }
        bpmButton.setTitle("\(bpm) BPM", for: .normal)
        currentScene.resetBall()
    }
    
    func displayTime(){
        var gameSeconds = data.integer(forKey: "runSeconds")
        if gameSeconds == 0{
            gameSeconds = 120
            data.set(gameSeconds, forKey: "runSecond")
        }
        DurationButton.setTitle("Duration: " + gameSeconds.displayTime(), for: .normal)
    }
    @IBAction func stoppedChooserChanged(_ sender: UISegmentedControl) {
        data.set(sender.selectedSegmentIndex, forKey: Keys.stopLevel)
    }
    
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 || sender.selectedSegmentIndex == 1{
            data.set(true, forKey: "listening")
        }else{
            data.set(false, forKey: "listening")
        }
    }
    
    @IBAction func topNotePan(recognizer:UIPanGestureRecognizer){ // this can be dried up.
        func displayAndReset(){
            currentScene.displayNotes()
            positionRangeText()
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        let translationLimit:CGFloat = 20
        let touchLocation = recognizer.location(in: self.view)
        let translation = recognizer.translation(in: recognizer.view)
        if topNoteRect.contains(touchLocation){
            if translation.y > translationLimit{
                noteController.changeLimit(isTop: true, higher: false)
                displayAndReset()
            }else if translation.y < -translationLimit{
                noteController.changeLimit(isTop: true, higher: true)
                displayAndReset()
            }
        }else if bottomNoteRect.contains(touchLocation){
            if translation.y > translationLimit{
                noteController.changeLimit(isTop: false, higher: false)
                displayAndReset()
            }else if translation.y < -translationLimit{
                noteController.changeLimit(isTop: false, higher: true)
                displayAndReset()
            }
        }else{
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
    }

}

extension FrontPageViewController: UIViewControllerTransitioningDelegate{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return transition
    }

//MARK: - Microphone Access Check
    func checkMicAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
            case .authorized:
                return
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .audio) { granted in
                    if granted {
                        return
                    } else {
                        self.showMicAlert()
                    }
                    return
                }
            case .denied: // The user has previously denied access.
                showMicAlert()
                return

            case .restricted: // The user can't grant access due to restrictions.
                showMicAlert()
                return
            @unknown default:
                fatalError("Wierd Mic Check Case")
        }
    }
    
    func showMicAlert() {
        let alert = UIAlertController(title: "Error", message: "Please allow microphone usage from settings", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open settings", style: .default, handler: { action in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
