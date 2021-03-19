//
//  TickHolder.swift
//  Farkas
//
//  Created by Stephen Nicholls on 19/02/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import SpriteKit

class TickHolder: SKSpriteNode{
    
    let tick = SKSpriteNode(imageNamed: "tick")
    let cross = SKSpriteNode(imageNamed: "cross")
    let displayDuration: TimeInterval = 0.5
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: nil, color: .clear, size: CGSize.zero)
        sortSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sortSprites(){
        tick.size = CGSize(width: 90, height: 60)
        cross.size = CGSize(width: 80, height: 60)
        tick.isHidden = true
        cross.isHidden = true
        addChild(tick)
        addChild(cross)
    }
    
    func display(isCorrect: Bool){
        var spriteToDisplay = tick
        if !isCorrect{
            spriteToDisplay = cross
        }
        let turnOnAction = SKAction.run{spriteToDisplay.isHidden = false}
        let turnOffAction = SKAction.run {spriteToDisplay.isHidden = true}
        let fadeOutAction = SKAction.fadeOut(withDuration: displayDuration)
        let fadeInAgain = SKAction.fadeIn(withDuration: 0)
        let waitAction = SKAction.wait(forDuration: displayDuration)
        let displayActions = [turnOnAction, waitAction, fadeOutAction, turnOffAction, fadeInAgain]
        let displaySequence = SKAction.sequence(displayActions)
        run(displaySequence)
        
    }
}
