//
//  AudioController.swift
//  AudioKitTest
//
//  Created by Stephen Nicholls on 19/02/2021.
//

import Foundation
import AudioKit

struct NoteWithIntonation{
    var noteNum: Int
    var tuning: Double
}

struct AudioController {
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    var AFrequency = 440.0
    var transpositionAdjustment = 0
    
    var amplitude: Double {
        return tracker.amplitude
    }
    
    var aboveMinimumAmplitude: Bool {
        return amplitude > 0.07
    }
    
    var currentNote: Int {
        get {
            if aboveMinimumAmplitude {
                let frequency = tracker.frequency
                return Int(round(getNoteNumber(freq: frequency)))
            }
            return -100
        }
    }
    
    var currentNoteWithIntonation: NoteWithIntonation {
        get {
            if aboveMinimumAmplitude {
                let frequency = tracker.frequency
                let note = getNoteNumber(freq: frequency)
                let noteToReturn = Int(round(note))
                let intonation = note - Double(noteToReturn)
                return NoteWithIntonation(noteNum: noteToReturn, tuning: intonation)
            }
            return NoteWithIntonation(noteNum: -100, tuning: 0.0)
        }
    }
    
    init() {
        AKSettings.sampleRate = AKManager.engine
                                            .inputNode
                                            .inputFormat(forBus: 0)
                                            .sampleRate
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
 
        AKManager.output = silence
        do {
            try AKManager.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        
        transpositionAdjustment = UserDefaults.standard.integer(forKey: "transpositionAdjustment")
    }
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
    
//    func getAmplitude() -> Double{
//        return tracker.amplitude
//    }
//
    func getNoteNumber(freq: Double) -> Double {  // computated property this
            var f = freq
            if f <= 0.1{
                f = 0.1
            }
            let ratio = f/AFrequency
            let noteNumber = 12.0 * log2(ratio)
            let transposedNoteNumber = transposeNote(note: noteNumber)
            return transposedNoteNumber
    }
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
    
    func transposeNote(note: Double) -> Double{ // this?
        return note + transpositionAdjustment + 9.0 // Adding 9 as we're basing it on A rather than C
    }
    
    func shutDown(){
        AKSettings.audioInputEnabled = false
        do{
            try AKManager.stop()
        } catch {
            AKLog("Audiokit did not stop!")
            print("AK Stop Failed")
        }
    }
}
