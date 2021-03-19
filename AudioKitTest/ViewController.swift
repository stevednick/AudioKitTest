//
//  ViewController.swift
//  AudioKitTest
//
//  Created by Stephen Nicholls on 19/02/2021.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var noteNumLabel: UILabel!
    @IBOutlet weak var tuningNumLabel: UILabel!
    
    lazy var audioController = AudioController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let newNote = self.audioController.currentNoteWithIntonation
            DispatchQueue.main.async {
                self.noteNumLabel.text = String(newNote.noteNum)
                self.tuningNumLabel.text = String(format: "%.2f" ,newNote.tuning)
            }
        }
    }
}

