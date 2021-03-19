//
//  NoteSelectioViewController.swift
//  Farkas
//
//  Created by Stephen Nicholls on 31/01/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import UIKit

class NoteSelectionViewController: UIViewController{
    
    let noteStore = UserDefaults.standard
    @IBOutlet var NoteSwitches: [UISwitch]!
    var allowedNotes: [Bool] = [true, true, true, true, true, true, true, true, true, false, true, true, true, false, false, true, true, false, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSwitches()
    }
    
    @IBAction func close(){
         dismiss(animated: true, completion: nil)
     }
    
    func setSwitches(){
        if noteStore.bool(forKey: "notesStored"){
            getNotes()
        }
        for sw in NoteSwitches{
            sw.isOn = allowedNotes[sw.tag]
        }
    }
    
    @IBAction func switchChnged(sender: UISwitch){
        allowedNotes[sender.tag] = sender.isOn
        storeNotes()
    }

    func storeNotes(){
        if allOff(){
            allowedNotes[0] = true
        }
        noteStore.set(allowedNotes, forKey: "allowedNotes")
        noteStore.set(true, forKey: "notesStored")
        noteStore.set(true, forKey: "switchesChanged")
    }
    
    func allOff() -> Bool{
        for s in allowedNotes{
            if s{
                return false
            }
        }
        return true
    }
    func getNotes(){
        allowedNotes = noteStore.array(forKey: "allowedNotes") as? [Bool] ?? [Bool]()
    }
    deinit {
        storeNotes()
    }
}
