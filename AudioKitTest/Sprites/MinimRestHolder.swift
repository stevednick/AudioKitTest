//
//  MinimRestHolder.swift
//  Farkas
//
//  Created by Stephen Nicholls on 11/02/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import SpriteKit

class MinimRestHolder: SKSpriteNode{  // Change this into a generic rest holder, or start a new one which you can just ask for the preferred clef. 
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: nil, color: .clear, size: CGSize.zero)
        load()
    }
    
    func load(){
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: 32, height: Data().lineGap/3))
        let line = SKShapeNode(path: path)
        line.lineWidth = 1
        line.fillColor = .black
        line.strokeColor = .black
        addChild(line)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
