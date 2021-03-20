//
//  OptionsViewController.swift
//  Farkas
//
//  Created by Stephen Nicholls on 06/04/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import UIKit

class OptionsViewController: UIViewController, SettingsPickerViewControllerDelegate, UITextFieldDelegate{
    
    let data = UserDefaults.standard
    weak var delegate : LoadedViewControllerDelegate?
    
    @IBOutlet weak var instrumentLabel: UILabel!
    @IBOutlet weak var clefLabel: UILabel!
    @IBOutlet weak var concertATextField: UITextField!
    @IBOutlet weak var shakeSwitch: UISwitch!
    @IBOutlet weak var sensitivityChooser: UISegmentedControl!
    @IBOutlet weak var tuningChooser: UISegmentedControl!
    @IBOutlet weak var feedbackSwitch: UISwitch!
    
    func load() {
        sortLabels()
        concertATextField.delegate = self
    }
    
    func sortLabels(){
        tuningChooser.selectedSegmentIndex = data.integer(forKey: Keys.tuningLevel)
        let currentInstrument = InstrumentStore().getInstrumentName()
        let currentTransposition = InstrumentStore().getCurrentTranspositionName()
        instrumentLabel.text = "\(currentInstrument ) in \(currentTransposition )"
        let clefs = InstrumentStore().clefNames
        if clefs[1] == "null"{
            let clefText = clefs[0].prefix(1).uppercased() + clefs[0].dropFirst() + " Clef Only"
            clefLabel.text = clefText
        }else{
            let topClefText = clefs[0].prefix(1).uppercased() + clefs[0].dropFirst()
            let bottomClefText = clefs[1].prefix(1).uppercased() + clefs[1].dropFirst()
            let clefText = topClefText + "/" + bottomClefText + " Clef"
            clefLabel.text = clefText
        }
        var concertA = data.integer(forKey: Keys.concertA)
        if concertA == 0{
            data.set(440, forKey: Keys.concertA)
            concertA = 440
        }
        concertATextField.text = "\(concertA)"
        shakeSwitch.isOn = data.bool(forKey: Keys.shakeOn) // Find a way to set this to true for first startup?
        sensitivityChooser.selectedSegmentIndex = data.integer(forKey: Keys.forgiveness)
        feedbackSwitch.isOn = data.bool(forKey: Keys.feedbackOn)
    }
    
    @IBAction func sensitivityChanged(_ sender: UISegmentedControl) {
        data.set(sender.selectedSegmentIndex, forKey: Keys.forgiveness)
    }
    
    @IBAction func close(){
        self.delegate?.reloadScreen()
        dismiss(animated: true, completion: nil)
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    @IBAction func highScoreButtonClicked(_ sender: UIButton) {
        showHighScoreAlert()
    }
    
    @IBAction func shakeSwitchChanged(_ sender: UISwitch) {
        data.set(sender.isOn, forKey: Keys.shakeOn)
    }
    
    @IBAction func tuningChooserChanged(_ sender: UISegmentedControl) {
        data.set(sender.selectedSegmentIndex, forKey: Keys.tuningLevel)
    }
    
    @IBAction func feedbackSwitchChanged(_ sender: UISwitch) {
        data.set(sender.isOn, forKey: Keys.feedbackOn)
    }
    
    
    func resetHighScores(){
        data.set(0.0, forKey: Keys.highScore)
        data.set(0.0, forKey: Keys.endlessHighScore)
        //data.set(0.0, forKey: Keys.bestHeldNoteTime)
        data.set(0, forKey: Keys.blitzNotes)
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
    
    func setConcertA(){
        guard let newConcertA = Int(concertATextField.text!) else{
            concertATextField.text = String(data.integer(forKey: Keys.concertA))
            return
        }
        if newConcertA >= 410 && newConcertA <= 450{
            data.set(newConcertA, forKey: Keys.concertA)
        }else{
            concertATextField.text = String(data.integer(forKey: Keys.concertA))
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        setConcertA()
        concertATextField.resignFirstResponder()
        return true
    }
}
