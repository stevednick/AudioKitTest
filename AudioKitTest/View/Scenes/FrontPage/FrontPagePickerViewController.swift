//
//  FrontPagePickerViewController.swift
//  Farkas
//
//  Created by Stephen Nicholls on 10/02/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import UIKit

class FrontPagePickerViewController: UIViewController{
    
    var minutes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
    var seconds = [0, 10, 20, 30, 40, 50]
    var minuteValue = 0
    var secondValue = 10
    var bpmPicker = false
    var currentBpm = 30
    
    var bpmList = [30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 63, 66, 69, 72, 76, 80, 84, 88, 92, 96, 100, 104, 108, 112, 116, 120, 126, 132, 138, 144, 152, 160, 168, 176, 184, 192, 200]
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var picker: UIPickerView!
    
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet var timeLabels: [UILabel]!
    let data = UserDefaults.standard
    
    weak var delegate: FrontPagePickerViewControllerDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.picker.delegate = self
        self.picker.dataSource = self
        loadData()
        setRows()
        if bpmPicker{
            for label in timeLabels{
                label.isHidden = true
                
            }
            navItem.title = "Set BPM"
        }else{
            bpmLabel.isHidden = true
            navItem.title = "Set Exercise Duration"
        }
    }
    
    @IBAction func close(){
        saveData()
        self.delegate?.displayTime()
        self.delegate?.displayBPM()
        dismiss(animated: true, completion: nil)
     }
    
    func loadData(){
        let t = data.integer(forKey: "runSeconds")
        if t > 0{
            secondValue = t % 60
            minuteValue = (t - secondValue) / 60
        }
        currentBpm = data.integer(forKey: "bPM")
    }
    
    func saveData(){
        let runSeconds = minuteValue * 60 + secondValue
        data.set(runSeconds, forKey: "runSeconds")
        data.set(currentBpm, forKey: "bPM")
        
    }
}

extension FrontPagePickerViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func setRows(){
        if !bpmPicker{
            picker.selectRow(seconds.firstIndex(of: secondValue) ?? 0, inComponent: 1, animated: true)
            picker.selectRow(minutes.firstIndex(of: minuteValue) ?? 0, inComponent: 0, animated: true)
        }else{
            picker.selectRow(bpmList.firstIndex(of: currentBpm) ?? 0, inComponent: 0, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if !bpmPicker{
            return 2
        }else{
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if !bpmPicker{
            if component == 0 {
                return minutes.count
            }
            else{
                return seconds.count
            }
        }else{
            return bpmList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if !bpmPicker{
            if component == 0{
                if secondValue == 0 && row == 0{
                    picker.selectRow(1, inComponent: 1, animated: true)
                    secondValue = seconds[1]
                }
                minuteValue = minutes[row]
            }else if component == 1{
                secondValue = seconds[row]
                if minuteValue == 0 && row == 0{
                    picker.selectRow(1, inComponent: 1, animated: true)
                    secondValue = seconds[1]
                }
                
            }
        }else{
            currentBpm = bpmList[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if !bpmPicker{
            if component == 0{
                return String(minutes[row])
            }else{
                return String(format:"%02i", seconds[row])
            }
        }else{
            return String(bpmList[row])
        }
    }
}
