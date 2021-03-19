//
//  StaveHolder.swift
//  Farkas
//
//  Created by Stephen Nicholls on 26/01/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class staveHolder: SKSpriteNode{
    
    let staveHolder = SKSpriteNode()
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: nil, color: .clear, size: CGSize(width: 2000, height: 100))
        addStave()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addStave(){
        for y in [-Data().lineGap*2, -Data().lineGap, 0, Data().lineGap, Data().lineGap*2]{
            let path = CGMutablePath()
            path.addRect(CGRect(x: -1000, y: CGFloat(y), width: 2000, height:Data().lineWidth))
            let line = SKShapeNode(path: path)
            line.lineWidth = 1
            line.fillColor = .black
            line.strokeColor = .black
            addChild(line)
        }
    }
}
