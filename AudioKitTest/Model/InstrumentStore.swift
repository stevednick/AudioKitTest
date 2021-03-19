//
//  InstrumentStore.swift
//  Farkas
//
//  Created by Stephen Nicholls on 10/02/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation

struct Instrument{
    var name: String?
    var transpositions: [Int: String]
    var preferredTransposition: Int
    var clefs: [Int]
    var preferredClef: Int
}

class InstrumentStore{ // Could this be stored as a JSON? Yes it could.
    
    
    let data = UserDefaults.standard
    
    let clefCombos = ["Treble", "Alto", "Tenor", "Bass", "Treble/Bass", "Alto/Bass", "Tenor/Bass", "Treble/Tenor", "Treble/Alto", "Alto/Tenor", "Alto/Bass"]
    
    let clefReturns = [["treble", "null"], ["alto", "null"], ["tenor", "null"], ["bass", "null"], ["treble", "bass"], ["alto", "bass"], ["tenor", "bass"], ["treble", "tenor"], ["treble", "alto"], ["alto", "tenor"], ["alto", "bass"]]
    
    let horn = Instrument(
        name: "Horn",
        transpositions: [
            0 : "C Alto",
            1 : "B Alto",
            2 : "Bb Alto",
            3 : "A Alto",
            4 : "Ab Alto",
            5 : "G",
            6 : "Gb/F#",
            7 : "F",
            8 : "E",
            9 : "Eb",
            10 : "D",
            11 : "Db/C#",
            12 : "C Basso",
            13 : "B/H Basso",
            14 : "Bb Basso",
            15: "A Basso",
            16: "Ab Basso"
        ],
        preferredTransposition: 7,
        clefs: [0, 3, 4],
        preferredClef: 0)
    
    let trumpet = Instrument(
        name: "Trumpet",
        transpositions: [
            -10 : "Bb (Piccolo)",
            -9 : "A (Piccolo)",
            -5 : "F",
            -4 : "E",
            -3 : "Eb",
            -2 : "D",
            0 : "C",
            1 : "B",
            2 : "Bb",
            3 : "A",
            4 : "Ab",
            7 : "F Basso"
        ],
        preferredTransposition: 2,
        clefs: [0],
        preferredClef: 0)
    
    let trombone = Instrument(
        name: "Trombone",
        transpositions:[
            0: "C",
            2 : "Bb"
        ],
        preferredTransposition: 0,
        clefs: [1, 2, 3, 5, 6, 9],
        preferredClef: 3)
    
    let tuba = Instrument(
        name: "Tuba",
        transpositions: [
            0 : "C",
            21 : "Eb (Brass Band)",
            26 : "Bb (Brass Band)"
        ],
        preferredTransposition: 0,
        clefs: [3, 0],
        preferredClef: 3)
    
    let clarinet = Instrument(
        name: "Clarinet",
        transpositions: [
            -3 : "Eb",
            0 : "C",
            2 : "Bb",
            3 : "A",
            7 : "F (Basset Horn)",
            14 : "Bb (Bass Clarinet)"
        ],
        preferredTransposition: 2,
        clefs: [0, 3],
        preferredClef: 0)
    
    let flute = Instrument(
        name: "Flute",
        transpositions: [
            -12 : "C (Piccolo)",
            0 : "C",
            5 : "G (Alto)",
            12 : "C (Bass)"
        ],
        preferredTransposition: 0,
        clefs: [0],
        preferredClef: 0)
    
    let bassoon = Instrument(
        name: "Bassoon",
        transpositions: [
            0 : "C (Bassoon)",
            12 : "C (Contra)"
        ],
        preferredTransposition: 0,
        clefs: [3, 0, 2, 6, 4, 7],
        preferredClef: 3)
    
    let oboe = Instrument(
        name: "Oboe",
        transpositions: [
            0 : "C (Oboe)",
            7 : "F (Cor Anglais)"
        ],
        preferredTransposition: 0,
        clefs: [0],
        preferredClef: 0)
    
    let recorder = Instrument(
        name: "Recorder",
        transpositions: [
            -12 : "C (Descant)",
            0 : "C"
        ],
        preferredTransposition: 0,
        clefs: [0],
        preferredClef: 0)
    
    let custom = Instrument(
        name: "Custom",
        transpositions: [
            
            -12 : "C (+12)",
            -11 : "B (+11)",
            -10 : "Bb (+10)",
            -9 : "A (+9)",
            -8 : "Ab (+8)",
            -7 : "G (+7)",
            -6 : "F# (+6)",
            -5 : "F (+5)",
            -4 : "E (+4)",
            -3 : "Eb (+3))",
            -2 : "D (+2)",
            -1 : "Db/C# (+1)",
            0 : "C",
            1 : "B (-1)",
            2 : "Bb (-2)",
            3 : "A (-3)",
            4 : "Ab (-4))",
            5 : "G (-5)",
            6 : "Gb/F# (-6)",
            7 : "F (-7)",
            8 : "E (-8)",
            9 : "Eb (-9)",
            10 : "D (-10)",
            11 : "Db/C# (-11)",
            12 : "C (-12)",
            13 : "B/H (-13)",
            14 : "Bb (-14)",
        ],
        preferredTransposition: 0,
        clefs: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        preferredClef: 0)
    
    var instruments: [Instrument] = [Instrument]()
    var currentInstrument = 0
    var currentTransposition = 0
    var currentClef = 0
    
    init(){
        instruments = [trumpet, horn, trombone, tuba, flute, clarinet, oboe, bassoon, recorder, custom]
        loadData()
    }
    
    func loadData(){
        
        if !data.bool(forKey: Keys.instrumentLoaded){ // Move this to front Page? Works here so probably not!. 
            data.set(1, forKey: Keys.currentInstrument)
            data.set(7, forKey: Keys.transpositionAdjustment)
            data.set(true, forKey:  Keys.instrumentLoaded)
        }
        currentInstrument = data.integer(forKey: Keys.currentInstrument)
        currentTransposition = data.integer(forKey: Keys.transpositionAdjustment)
        currentClef = data.integer(forKey: Keys.currentClef)
    }
    
    func saveData(){
        data.set(currentInstrument, forKey: Keys.currentInstrument)
        data.set(currentTransposition, forKey: Keys.transpositionAdjustment)
        data.set(currentClef, forKey: Keys.currentClef)
        data.set(clefReturns[currentClef][0], forKey: Keys.topClef)
        data.set(clefReturns[currentClef][1], forKey: Keys.bottomClef)
    }
    
    func getInstrumentName() -> String{
        return instruments[currentInstrument].name ?? "Missing Instrument Name"
    }
    
    func getTranspositionLocation() -> Int{
        let instrument = instruments[currentInstrument]
        let indexArray = Array(instrument.transpositions.keys).sorted()
        return indexArray.firstIndex(of: currentTransposition) ?? 0
    }
    
    func getCurrentTranspositionName() -> String{
        let instrument = instruments[currentInstrument]
        return instrument.transpositions[currentTransposition] ?? "Missing Transposition Name"
    }
    
    func getClefLocation() -> Int{
        let instrument = instruments[currentInstrument]
        return instrument.clefs.firstIndex(of: currentClef) ?? 0
    }
    
    func getTranspositionCount() -> Int{
        let instrument = instruments[currentInstrument]
        let indexArray = Array(instrument.transpositions.keys).sorted()
        return indexArray.count
    }
    
    func getClefCount() -> Int{
        let instrument = instruments[currentInstrument]
        return instrument.clefs.count
    }
    
    func getInstrumentNames() -> [String]{
        var instrumentNames = [String]()
        for instrument in instruments{
            instrumentNames.append(instrument.name ?? "Name Missing!")
        }
        return instrumentNames
    }
    
    func getTranspositions() -> [String]{
        let instrument = instruments[currentInstrument]
        var transpositions = [String]()
        for i in -28...28{
            if instrument.transpositions[i] != nil{
                transpositions.append(instrument.transpositions[i] ?? "Missing Transposition")
            }
        }
        return transpositions 
    }
    
    func getClefs() -> [String]{
        let instrument = instruments[currentInstrument]
        var clefs = [String]()
        for num in instrument.clefs{
            clefs.append(clefCombos[num])
        }
        return clefs
    }
    
    func getClefNames() -> [String]{
        return clefReturns[currentClef]
    }
    
    func changeInstrument(inst: Int){
        currentInstrument = inst
        currentTransposition = instruments[currentInstrument].preferredTransposition
        currentClef = instruments[currentInstrument].preferredClef
    }
    
    func setTransposition(row: Int){
        let instrument = instruments[currentInstrument]
        let indexArray = Array(instrument.transpositions.keys).sorted()
        currentTransposition = indexArray[row]
    }
    
    func setClef(row: Int){
        let instrument = instruments[currentInstrument]
        currentClef = instrument.clefs[row]
    }
    
    deinit {
        saveData()
    }
}
