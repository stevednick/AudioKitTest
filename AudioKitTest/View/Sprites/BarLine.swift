//
//  BarLine.swift
//  Farkas
//
//  Created by Stephen Nicholls on 29/01/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import SpriteKit

class BarLine: SKSpriteNode{
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: nil, color: .clear, size: CGSize.zero)
        addBarLine()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBarLine(){
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: -Data().lineGap * 2, width: Data().lineWidth * 2, height: Data().lineGap * 4))
        let line = SKShapeNode(path: path)
        line.lineWidth = 1
        line.fillColor = .black
        line.strokeColor = .black
        addChild(line)
    }
}

