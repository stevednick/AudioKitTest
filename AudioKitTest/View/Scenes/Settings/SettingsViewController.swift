//
//  SettingsViewController.swift
//  Farkas
//
//  Created by Stephen Nicholls on 05/02/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import UIKit

protocol SettingsPickerViewControllerDelegate: class{
    func load()
}

class SettingsViewController: UIViewController, SettingsPickerViewControllerDelegate{

    @IBOutlet weak var lowerButton: UIButton!
    @IBOutlet weak var upperButton: UIButton!
    @IBOutlet weak var transpositionButton: UIButton!
    @IBOutlet weak var instrumentButton: UIButton!
    weak var delegate : LoadedViewControllerDelegate?
    let data = UserDefaults.standard
    
    var instrumentData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    @IBAction func close(){
        self.delegate?.reloadScreen()
        dismiss(animated: true, completion: nil)
     }
    
    func load(){
        let currentTransposition = InstrumentStore().getCurrentTranspositionName()
        let currentInstrument = InstrumentStore().getInstrumentName()
        let currentTopClef = data.string(forKey: "topClef") ?? "treble"
        let currentBottomClef = data.string(forKey: "bottomClef") ?? "null"
        let displayUpper = currentTopClef.prefix(1).uppercased() + currentTopClef.dropFirst() + " Clef"
        var displayLower = "None"
        if currentBottomClef != "null"{
            displayLower = currentBottomClef.prefix(1).uppercased() + currentBottomClef.dropFirst() + " Clef"
        }
        transpositionButton.setTitle(currentTransposition, for: .normal)
        instrumentButton.setTitle(currentInstrument, for: .normal)
        upperButton.setTitle(displayUpper, for: .normal)
        lowerButton.setTitle(displayLower, for: .normal)
    }
    @IBAction func highScoreButtonClicked(_ sender: UIBarButtonItem) {
        showHighScoreAlert()
    }
    
    func resetHighScores(){
        data.set(0.0, forKey: Keys.highScore)
        data.set(0.0, forKey: Keys.endlessHighScore)
        data.set(0.0, forKey: Keys.bestHeldNoteTime)
        data.set(0.0, forKey: Keys.blitzHighScore)
        print("High Scores Reset")
    }
    
    func showHighScoreAlert(){
        let alert = UIAlertController(title: "Reset High Scores", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {action in
            self.resetHighScores()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PickerViewController{
            let vc = segue.destination as? PickerViewController
            vc?.delegate = self
        }
    }
}
