//
//  Data.swift
//  Farkas
//
//  Created by Stephen Nicholls on 25/01/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import SpriteKit

class Data{ // Does this need to still exist, or can I spread it in where necessary? 
        
    let defaults = UserDefaults.standard
    
    let lineGap: CGFloat = 25
    let lineWidth: CGFloat = 0.8
    let objectColour: SKColor = .black
    var topClef = "treble"
    var bottomClef = "null"
    var clefOverlap = 1
    var difficulty = 1
    var topNote = 23
    var bottomNote = 11
    
    func saveData(){  // This is all which is left? Do we need to move? 
        defaults.set(true, forKey: "hasSaved")
        defaults.set(topClef, forKey: Keys.topClef)
        defaults.set(bottomClef, forKey: Keys.bottomClef)
        defaults.set(clefOverlap, forKey: Keys.clefOverlap)
        defaults.set(difficulty, forKey: Keys.difficulty)
        defaults.set(topNote, forKey: Keys.topNote)
        defaults.set(bottomNote, forKey: Keys.bottomNote)
    }
    
    func loadData(){
        if defaults.bool(forKey: "hasSaved"){
            topClef = defaults.string(forKey: Keys.topClef) ?? "treble"
            bottomClef = defaults.string(forKey: Keys.bottomClef) ?? "bass"
            clefOverlap = defaults.integer(forKey: Keys.clefOverlap)
            difficulty = defaults.integer(forKey: Keys.difficulty)
            topNote = defaults.integer(forKey: Keys.topNote)
            bottomNote = defaults.integer(forKey: Keys.bottomNote)
            
        }
    }
    
}
