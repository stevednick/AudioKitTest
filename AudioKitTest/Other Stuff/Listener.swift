//
//  Listener.swift
//  Farkas
//
//  Created by Stephen Nicholls on 25/01/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import AudioKit
import SpriteKit
//
//struct NoteWithIntonation{
//    var noteNum: Int
//    var tuning: Double
//}
//
//class Listener: SKNode{ // Do we need to catch when the mic cannot be loaded to stop it crashing? Pop up a warning instead? 
//
//    let listener = SKNode()
//    var mic: AKMicrophone!
//    var tracker: AKFrequencyTracker!
//    var silence: AKBooster!
//    var AFrequency = 440.0
//    var transpositionAdjustment = 0
//    let noteStore = UserDefaults.standard
//    let data = UserDefaults.standard
//
//    override init() {
//        super.init()
//        setUp()
//    }
//    
//    deinit {
//        AKSettings.audioInputEnabled = false
//        do{
//            try AKManager.stop()
//        } catch {
//            AKLog("Audiokit did not stop!")
//            print("AK Stop Failed")
//        }
//    }
//    
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    func setUp() {
//        if data.integer(forKey: Keys.concertA) > 0{
//            AFrequency = Double(data.integer(forKey: Keys.concertA))
//        }
//        transpositionAdjustment = noteStore.integer(forKey: "transpositionAdjustment")
//        AKSettings.sampleRate = AKManager.engine
//                                            .inputNode
//                                            .inputFormat(forBus: 0)
//                                            .sampleRate
//        AKSettings.audioInputEnabled = true
//        mic = AKMicrophone()
//        tracker = AKFrequencyTracker(mic)
//        silence = AKBooster(tracker, gain: 0)
// 
//        AKManager.output = silence
//        do {
//            try AKManager.start()
//        } catch {
//            AKLog("AudioKit did not start!")
//        }
//    }
//
//    func updateUI() -> Int {
//        if tracker.amplitude > 0.1 {
//            let frequency = Float(tracker.frequency)
//            return Int(getNoteNumber(freq: Double(frequency)))
//        }
//        return -100
//    }
//    
//    func getCurrentNote() -> Int {
//        if checkMinimumAmplitude() {
//            let frequency = tracker.frequency
//            return Int(round(getNoteNumber(freq: frequency)))
//        }
//        return -100
//    }
//    
//    func checkMinimumAmplitude() -> Bool{
//        return tracker.amplitude > 0.07
//    }
//    
//    func getAmplitude() -> Double{
//        return tracker.amplitude
//    }
//    
//    func getNoteNumber(freq: Double) -> Double {
//            var f = freq
//            if f <= 0.1{
//                f = 0.1
//            }
//            let ratio = f/AFrequency
//            let noteNumber = 12.0 * log2(ratio)
//            let transposedNoteNumber = transposeNote(note: noteNumber)
//            return transposedNoteNumber
//    }
//    
//    func getNoteNumberWithIntonation() -> NoteWithIntonation{
//        if checkMinimumAmplitude(){
//            let frequency = tracker.frequency
//            let note = getNoteNumber(freq: frequency)
//            let noteToReturn = Int(round(note))
//            let intonation = note - Double(noteToReturn)
//            return NoteWithIntonation(noteNum: noteToReturn, tuning: intonation)
//        }
//        return NoteWithIntonation(noteNum: -100, tuning: 0.0)
//    }
//    
//    func transposeNote(note: Double) -> Double{
//        return note + transpositionAdjustment + 9.0 // Adding 9 as we're basing it on A rather than C
//    }
//}
