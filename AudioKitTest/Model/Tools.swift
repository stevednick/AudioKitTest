//
//  Tools.swift
//  Farkas
//
//  Created by Stephen Nicholls on 04/03/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


struct note{ // modified this to hold it's own number. 
    var pos: Int
    var accidental: String
    var clef = "treble"
    var priority = 0
    var num = 0
    var flashing = false
}

enum Keys {
    static let highScore = "highScore"
    static let endlessHighScore = "endlessHighScore"
    static let blitzHighScore = "blitzHighScore"
    static let forgiveness = "forgiveness"
    static let bestHeldNoteTime = "bestHeldNoteTime"
    static let stopLevel = "stopLevel"
    static let currentInstrument = "currentInstrument"
    static let instrumentLoaded = "instrumentLoaded"
    static let transpositionAdjustment = "transpositionAdjustment"
    static let currentClef = "currentClef"
    static let topClef = "topClef"
    static let bottomClef = "bottomClef"
    static let sharp = "sharp"
    static let flat = "flat"
    static let doubleSharp = "doubleSharp"
    static let doubleFlat = "doubleFlat"
    static let clefOverlap = "clefOverlap"
    static let difficulty = "difficulty"
    static let topNote = "topNote"
    static let bottomNote = "bottomNote"
    static let allowedNotes = "allowedNotes"
    static let blitzNotes = "blitzNotes"
    static let concertA = "concertA"
    static let shakeOn = "shakeOn"
    static let tuningLevel = "tuningLevel"
    static let feedbackOn = "feedbackOn"
    static let firstStartComplete = "firstStartComplete"
}

public extension SKLabelNode{
    
    func setUp(size: CGFloat){
        self.fontSize = size
        self.fontColor = .black
        self.fontName = "Avenir Next Regular"
    }
    
}

public extension UIColor {
    /// The RGBA components associated with a `UIColor` instance.
    var components: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let components = self.cgColor.components!

        switch components.count == 2 {
        case true : return (r: components[0], g: components[0], b: components[0], a: components[1])
        case false: return (r: components[0], g: components[1], b: components[2], a: components[3])
        }
    }

    /**
     Returns a `UIColor` by interpolating between two other `UIColor`s.
     - Parameter fromColor: The `UIColor` to interpolate from
     - Parameter toColor:   The `UIColor` to interpolate to (e.g. when fully interpolated)
     - Parameter progress:  The interpolation progess; must be a `CGFloat` from 0 to 1
     - Returns: The interpolated `UIColor` for the given progress point
     */
    static func interpolate(from fromColor: UIColor, to toColor: UIColor, with progress: CGFloat) -> UIColor {
        let fromComponents = fromColor.components
        let toComponents = toColor.components

        let r = (1 - progress) * fromComponents.r + progress * toComponents.r
        let g = (1 - progress) * fromComponents.g + progress * toComponents.g
        let b = (1 - progress) * fromComponents.b + progress * toComponents.b
        let a = (1 - progress) * fromComponents.a + progress * toComponents.a

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

public extension Double{
    func forDisplay() -> String{
        return String(format:"%.02f", self)
    }
    func insideOne() -> Double{
        if self < 0.0{
            return 0.0
        }
        if self > 1.0{
            return 1.0
        }
        return self
    }
}

public extension Int{
    func displayTime() -> String{
        let seconds = self % 60
        let minutes = (self - seconds) / 60
        return String(format:"%01i:%02i", minutes, seconds)
    }
}


