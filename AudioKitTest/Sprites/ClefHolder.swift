//
//  ClefHolder.swift
//  Farkas
//
//  Created by Stephen Nicholls on 26/01/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class clefHolder: SKSpriteNode{
    
    let clefHolder = SKSpriteNode()
    let trebleClef = SKSpriteNode(imageNamed: "treble")
    let bassClef = SKSpriteNode(imageNamed: "bass")
    let altoClef = SKSpriteNode(imageNamed: "altoClef")
    let tenorClef = SKSpriteNode(imageNamed: "altoClef")
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: nil, color: .clear, size: clefHolder.size)
        addClefs()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addClefs(){
        addClef(sprite: trebleClef, pos: CGPoint.zero, size: CGSize(width: 110, height: 190), anchor: CGPoint(x: 0.5, y: 0.51))
        addClef(sprite: bassClef, pos: CGPoint.zero, size: CGSize(width: 55, height: 74), anchor: CGPoint(x: 0.5, y: 0.325))
        addClef(sprite: altoClef, pos: CGPoint.zero, size: CGSize(width: 90, height: 100), anchor: CGPoint(x: 0.5, y: 0.5))
        addClef(sprite: tenorClef, pos: CGPoint(x: 0, y: 25), size: CGSize(width: 90, height: 100), anchor: CGPoint(x: 0.5, y: 0.5))
    }
    
    func addClef(sprite: SKSpriteNode, pos: CGPoint, size: CGSize, anchor: CGPoint){
        sprite.position = pos
        sprite.color = Data().objectColour
        sprite.colorBlendFactor = 1
        sprite.size = size
        sprite.anchorPoint = anchor
        addChild(sprite)
        sprite.isHidden = true
    }
    
    func displayClef(clef: String){
        for spriteAndName in [trebleClef: "treble", bassClef: "bass", altoClef: "alto", tenorClef: "tenor"]{
            spriteAndName.key.isHidden = clef != spriteAndName.value
        }
    }
    
    func changeColour(colour: SKColor){
        if trebleClef.color != colour{
            for sprite in [trebleClef, altoClef, tenorClef, bassClef]{
                sprite.color = colour
            }
        }
    }
}
