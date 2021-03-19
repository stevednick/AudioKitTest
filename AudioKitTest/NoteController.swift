//
//  NoteController.swift
//  Farkas
//
//  Created by Stephen Nicholls on 04/02/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation

class NoteController{
    
    let noteStore = UserDefaults.standard
    let notePositions = [0, 2, 4, 5, 7, 9, 11]
    let accidentalAdjustments = [0, 1, -1, 2, -2]
    
    let priorities: [Int] = [
        0, 0, 0, 0, 0, 0, 0,
        0, 1, 1, 0, 0, 1, 1,
        1, 1, 0, 1, 1, 1, 0,
        2, 2, 2, 1, 2, 2, 2,
        2, 2, 1, 2, 2, 2, 1
    ]
    
    let offsets = ["treble" : -6, "bass" : 6, "alto": 0, "tenor" : 2, "null" : 1000]
    let accidentalNames = ["null", "sharp", "flat", "doubleSharp", "doubleFlat"]
    var switchArray: [Bool] = [Bool]()
    let backUpSwitchArray: [Bool] = [true, true, true, true, true, true, true, true, true, false, true, true, true, false, false, true, true, false, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    
    var bottomNote: Int = 0
    var topNote: Int = 12
    var notesInOctave: [[note]] = [[note]]()
    var allNotes: [[note]] = [[note]]()
    var availableNotes: [Int] = [Int]()
    var topClef = "treble"
    var bottomClef = "bass"
    let allowedLedgers = 2
    var allTheNotes: [[note]] = [[note]]()
    
    init() {
        load()
    }
    
    func load(){
        
        topClef = noteStore.string(forKey: Keys.topClef) ?? "treble"
        bottomClef = noteStore.string(forKey: Keys.bottomClef) ?? "bass"
        
        (bottomNote, topNote) = getLimits()
        if bottomNote >= topNote{
            bottomNote = 0
            topNote = 12
            setLimits()
            print("Notes adjusted due to being too close!")
        }
        
        switchArray = noteStore.array(forKey: Keys.allowedNotes) as? [Bool] ?? [Bool]()
        if switchArray.isEmpty{
            print("Found Empty Switch Array!")
            switchArray = backUpSwitchArray
            noteStore.set(switchArray, forKey: Keys.allowedNotes)
        }
        
        allTheNotes = assembleAllNotesArray()
        notesInOctave = assembleNoteInOctaveArray(switches: switchArray)
        availableNotes = assembleAvailableNotesList()
        if availableNotes.count < 2{
            topNote += 12
            setLimits()
            availableNotes = assembleAvailableNotesList()
        }
    }
    
    func switchesHaveChanged() -> Bool{
        return noteStore.bool(forKey: "switchesChanged")
    }
    
    func getRandomNote() -> note{
        if switchesHaveChanged(){
            load()
        }
        let randomNoteNum = availableNotes.randomElement() ?? 0
        let posInOctave = getPosInOctave(noteNum: randomNoteNum)
        let octave = getOctave(num: randomNoteNum)
        var noteToReturn = notesInOctave[posInOctave].randomElement()
        noteToReturn?.pos += octave * 7
        noteToReturn = sortClef(note: noteToReturn!)
        noteToReturn?.num = randomNoteNum
        return (noteToReturn ?? note(pos: 0, accidental: "null", clef: "treble"))
    }
    
    func getRandomNoteWithRestrictions(maxPriority: Int, rangeReduction: Double) -> note{ // this needs some tweaking I'm sure! 
        func calculateReducedRange() -> (Int, Int){
            let reduction = rangeReduction.insideOne()
            let currentTop = noteStore.integer(forKey: Keys.topNote)
            let currentBottom = noteStore.integer(forKey: Keys.bottomNote)
            let range = currentTop - currentBottom
            let maxReduction = Double(range)/2.0 - 3.0
            var currentReduction = Int(maxReduction * (1-reduction))
            if currentReduction < 0{
                currentReduction = 0
            }
            return (currentTop - currentReduction, currentBottom + currentReduction)
        }

        let currentRange = calculateReducedRange()
        let num = Int.random(in: (currentRange.1..<currentRange.0))
        let posInOctave = getPosInOctave(noteNum: num)
        let octave = getOctave(num: num)
        var availableNotes: [note] = [note]()
        for n in (0..<allTheNotes[posInOctave].count){
            if allTheNotes[posInOctave][n].priority <= maxPriority{
                availableNotes.append(allTheNotes[posInOctave][n])
            }
        }
        var noteToReturn = availableNotes.randomElement()
        noteToReturn?.pos += octave * 7
        noteToReturn = sortClef(note: noteToReturn!)
        noteToReturn?.num = num
        return noteToReturn ?? note(pos: 0, accidental: "null", clef: "treble")
    }
    
    func getTopAndBottomNote() -> (note, note){
        
        load()
        let top = availableNotes.last!
        let bottom = availableNotes.first!
        let topNoteInOctave = getPosInOctave(noteNum: top)
        let topOctave = getOctave(num: top)
        let bottomNoteInOctave = getPosInOctave(noteNum: bottom)
        let bottomOctave = getOctave(num: bottom)
        var topNoteToReturn = getEasiestOption(num: topNoteInOctave)
        var bottomNoteToReturn = getEasiestOption(num: bottomNoteInOctave)
        topNoteToReturn.pos += topOctave * 7
        bottomNoteToReturn.pos += bottomOctave * 7
        return (sortClef(note: topNoteToReturn, true), sortClef(note: bottomNoteToReturn, true))
    }
    
    func getNotePlayed(num: Int) -> note{
        let noteInOctave = getPosInOctave(noteNum: num)
        let octave = getOctave(num: num)
        var noteToReturn = getEasiestOption(num: noteInOctave, true)
        noteToReturn.pos += octave * 7
        return (sortClef(note: noteToReturn, true))
    }
    
    func getOctave(num: Int) -> Int{
        var numInOctave = num % 12
        if numInOctave < 0{
            numInOctave += 12
        }
        return Int((num - numInOctave)/12)
    }
    
    func getEasiestOption(num: Int, _ forDisplay: Bool = false) -> note{ // Send this one the note in octave, not pos
        if forDisplay{
            for element in allTheNotes[num]{
                if element.priority == 0{
                    return element
                }
            }
            print("Something wrong trying to display note forDisplay")
            print(num)
            return note(pos: 0, accidental: "null", clef: "treble")
        }
        
        if notesInOctave[num].isEmpty{
            print("Tried to get Easiest Option of note not on list!")
            print(num)
            return note(pos: 0, accidental: "null", clef: "treble")
        }
        for element in notesInOctave[num]{
            if element.priority == 0{
                return element
            }
        }
        for element in notesInOctave[num]{
            if element.priority == 1{
                return element
            }
        }
        for element in notesInOctave[num]{
            if element.priority == 2{
                return element
            }
        }
        print ("Got to end of Easiest options without returning anything")
        return note(pos: 0, accidental: "null", clef: "treble")
    }
    
    func changeLimit(isTop: Bool, higher: Bool){
        if isTop && higher{
            if topNote < 50{
                topNote += 1
            }
        }else if !isTop && !higher{
            if bottomNote > -50{
                bottomNote -= 1
            }
        }else if isTop && !higher && availableNotes.count > 2{
            topNote -= 1
        }else if !isTop && higher && availableNotes.count > 2{
            bottomNote += 1
        }else{
            return
        }
        setLimits()
        load()
    }
    
    func getLimits() -> (Int, Int){
        let bottom = noteStore.integer(forKey: Keys.bottomNote)
        let top = noteStore.integer(forKey: Keys.topNote)
        return (bottom, top)
    }
    
    func setLimits(){
        noteStore.set(topNote, forKey: Keys.topNote)
        noteStore.set(bottomNote, forKey: Keys.bottomNote)
    }
    
    func assembleAvailableNotesList() -> [Int]{
        var availableNotes = [Int]()
        for num in bottomNote..<topNote{
            let posInOctave = getPosInOctave(noteNum: num)
            if notesInOctave[posInOctave].isNotEmpty{ // Check what is wrong with this. 
                availableNotes.append(num)
            }
        }
        return availableNotes
    }
    
    func getPosInOctave(noteNum : Int) -> Int{
        var posInOctave = noteNum % 12
        if posInOctave < 0{
            posInOctave += 12
        }
        return posInOctave
    }
    
    func assembleAllNotesArray() -> [[note]]{
        var notesInOctave:[[note]] = []
        for _ in 0 ... 11{
            notesInOctave.append([])
        }
        for pos in 0...34{
            
            let (noteNumber, note) = getPosInOctave(switchNum: pos)
            notesInOctave[noteNumber].append(note)
        }
        return notesInOctave
    }
    
    func assembleNoteInOctaveArray(switches: [Bool]) -> [[note]]{
        var notesInOctave:[[note]] = []
        for _ in 0 ... 11{
            notesInOctave.append([])
        }
        
        for (pos, isTrue) in switches.enumerated(){
            if isTrue{
                let (noteNumber, note) = getPosInOctave(switchNum: pos)
                notesInOctave[noteNumber].append(note)
            }
        }
        return notesInOctave
    }
    
    func getPosInOctave(switchNum: Int) -> (Int, note){
        var noteNum = switchNum % 7
        let accidental = Int(switchNum / 7)
        var numToReturn = notePositions[noteNum] + accidentalAdjustments[accidental]
        
        if numToReturn >= 12{
            numToReturn -= 12
            noteNum -= 7
        }else if numToReturn < 0{
            numToReturn += 12
            noteNum += 7
        }
        return (numToReturn, note(pos: noteNum, accidental: accidentalNames[accidental], priority: priorities[switchNum]))
    }
    
    func sortClef(note: note, _ display: Bool = false) -> note{
        var n = note
        let posOnTopClef = note.pos + offsets[topClef]!
        let posOnBottomClef = note.pos + offsets[bottomClef]!
        var ledgers = allowedLedgers // add ability to reduce this for display.
        if display{
            ledgers = 0
        }
        var isBottomClef = true
        
        if bottomClef == "null"{
            isBottomClef = false
        }else if posOnTopClef >= -6 - ledgers && posOnBottomClef <= 6 + ledgers{
            if Bool.random(){
                isBottomClef = false
            }
            if ledgers == 0{
                isBottomClef = false
            }
        }
        if posOnBottomClef > 6 + ledgers{
            isBottomClef = false
        }
        if isBottomClef{
            n.clef = bottomClef
            n.pos = posOnBottomClef
        }else{
            n.clef = topClef
            n.pos = posOnTopClef
        }
        return n
    }
    
    func getNumberOfSwitches() -> Int{
        let switchArray = noteStore.array(forKey: Keys.allowedNotes) as? [Bool] ?? [Bool]()
        var count = 0
        for s in switchArray{
            if s{
                count += 1
            }
        }
        return count
    }
    
    func getTotalRange() -> Int{
        let noteList = assembleAvailableNotesList()
        return (noteList.last ?? 12) - (noteList.first ?? 0)
    }
}
