//
//  NoteChecker.swift
//  Farkas
//
//  Created by Stephen Nicholls on 12/03/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation

struct NoteWithDuration{
    var noteNum: Int
    var duration: TimeInterval
    var intonation: Double = 0.0
}

class NoteChecker{
    
    var forgiveness = 3
    var noteToCheck = 0
    lazy var lis = AudioController()
    var prevNoteArray: [Int] = [Int]()
    var lastNoteHeard: Int = -100
    var lastNoteStartTime: TimeInterval = 100000000.0
    var intonationArray: [Double] = [Double]()
    var currentNote: Int {
        return lis.currentNote
    }
    
    func checkNote(noteToCheck: Int) -> Bool{
        let notePlayed = lis.currentNote
        return getNoteIfValid(noteToAdd: notePlayed) == noteToCheck
    }
    
    func getNoteIfValid(noteToAdd: Int) -> Int{
        prevNoteArray.append(noteToAdd)
        if prevNoteArray.count > 10{
            prevNoteArray.removeFirst()
        }
        let prevNoteSet = Array(Set(prevNoteArray))
        for note in prevNoteSet{
            if prevNoteArray.filter({$0 == note}).count >= (10 - forgiveness){
                return note
            }
        }
        return noteToAdd
    }
    
    func getCurrentNoteWithDuration(currentTime: TimeInterval) -> NoteWithDuration{
        let currentNote = getNoteIfValid(noteToAdd: lis.currentNote)
        if currentNote != lastNoteHeard{
            lastNoteStartTime = currentTime
            lastNoteHeard = currentNote
        }
        if currentNote <= -100{
            return NoteWithDuration(noteNum: -1000, duration: 0.0)
        }
        return NoteWithDuration(noteNum: currentNote, duration: currentTime - lastNoteStartTime)
    }
    
    func getCurrentNoteWithDurationandIntonation(currentTime: TimeInterval) -> NoteWithDuration{
        let mostRecentNote = lis.currentNoteWithIntonation
        let currentNote = getNoteIfValid(noteToAdd: mostRecentNote.noteNum)
        if currentNote != lastNoteHeard{
            lastNoteStartTime = currentTime
            lastNoteHeard = currentNote
            intonationArray = [Double]()
        }
        intonationArray.append(mostRecentNote.tuning)
        if currentNote <= -100{
            return NoteWithDuration(noteNum: -1000, duration: 0.0)
        }
        return NoteWithDuration(noteNum: currentNote, duration: currentTime - lastNoteStartTime, intonation: getAverageIntonation())
    }
    
    func getAverageIntonation() -> Double{
        let totalOfArray = intonationArray.reduce(0, +)
        let average = totalOfArray/Double(intonationArray.count)
        return average
    }
//
//    func getCurrentNote() -> Int{
//        return lis.currentNote
//    }
    
    deinit {
        lis.shutDown()
    }
    
}
