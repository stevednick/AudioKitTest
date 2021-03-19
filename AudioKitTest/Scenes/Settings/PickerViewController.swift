//
//  PickerViewController.swift
//  Farkas
//
//  Created by Stephen Nicholls on 05/02/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import UIKit

class PickerViewController: UIViewController{
    
    
    var viewController: SettingsViewController!
    @IBOutlet weak var picker: UIPickerView!
    
    let data = UserDefaults.standard
    let instrumentStore = InstrumentStore()
    var currentInstrument = 0
    var currentTransposition = 0
    var currentClefCombo = 0
    weak var delegate : SettingsPickerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewController = presentingViewController as? SettingsViewController
        currentClefCombo = data.integer(forKey: "clefCombo")
        self.picker.delegate = self
        self.picker.dataSource = self
        //loadData()
        setRows()
    }
    
    @IBAction func close(){
        instrumentStore.saveData()
        saveData()
        dismiss(animated: true, completion: nil)
     }
    
    
    func saveData(){
        self.delegate?.load()
        //viewController.load()
    }
}

extension PickerViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func setRows(){
        picker.selectRow(instrumentStore.currentInstrument, inComponent: 0, animated: true)
        picker.selectRow(instrumentStore.getTranspositionLocation(), inComponent: 1, animated: true)
        picker.selectRow(instrumentStore.getClefLocation(), inComponent: 2, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return instrumentStore.instruments.count
        }
        else if component == 1{
            return instrumentStore.getTranspositionCount()
        }else{
            return instrumentStore.getClefCount()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0{
            instrumentStore.currentInstrument = row // Change to getInstrument?
            instrumentStore.changeInstrument(inst: row)
            picker.reloadComponent(1)
            picker.reloadComponent(2)
            setRows()
        }
        
        else if component == 1{
            instrumentStore.setTransposition(row: row)
        }else{
            instrumentStore.setClef(row: row)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            return instrumentStore.getInstrumentNames()[row]
        }else if component == 1{
            return instrumentStore.getTranspositions()[row]
        }else{
            return instrumentStore.getClefs()[row]
        }
    }
}
