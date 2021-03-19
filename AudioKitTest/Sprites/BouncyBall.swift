//
//  BouncyBall.swift
//  Farkas
//
//  Created by Stephen Nicholls on 13/02/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import Foundation
import SpriteKit

class BouncyBall: SKSpriteNode{
    
    let data = UserDefaults.standard
    var circle = SKShapeNode()
    var nextLandingTime: TimeInterval = 0
    var lastLandingTime: TimeInterval = 0
    var tempo: Double = 30.0
    var beatDuration: TimeInterval = 0
    let acceleration = -800.0
    var initialVelocity = 400.0
    var nextJumpHeight = 0.0
    var startHeight = 0.0
    var endHeight = 0.0
    var ballScaleCooldown = 0
    var pauseState = false
    var pauseStarted = false
    var pauseStartTime: TimeInterval = 0.0
    var pauseTimeRemaining: TimeInterval = 0.0
    var reset = false
    
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: nil, color: .clear, size: CGSize.zero)
        load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pause(startPause: Bool){
        pauseState = startPause
    }
    
    func load(){
        tempo = Double(data.integer(forKey: "bPM"))
        beatDuration = 60/tempo
        circle = SKShapeNode(circleOfRadius: 12)
        circle.lineWidth = 1
        circle.fillColor = .black
        circle.strokeColor = .black
        addChild(circle)
    }
    
    func changeTempo(newTempo: Double){
        tempo = newTempo
        beatDuration = 60/tempo
    }
    
    func calculateInitialVelocity(startH: Double, endH: Double) -> Double{
        let difference = endH - startH
        return difference - acceleration / 2
        
    }
    
    func resetBeat(){
        reset = true
    }
    
    func regularBounce(currentTime: TimeInterval){
        if reset{
            endHeight = 0.0
            nextJumpHeight = 0.0
            startHeight = 0.0
            lastLandingTime = currentTime
            reset = false
        }
        if pauseState && !pauseStarted{
            pauseStartTime = currentTime
            pauseTimeRemaining = lastLandingTime + beatDuration - currentTime
            pauseStarted = true
            return
        }
        if !pauseState && pauseStarted{
            lastLandingTime = currentTime - beatDuration + pauseTimeRemaining
            pauseStarted = false
            return
        }
        if !pauseState && !pauseStarted{
            initialVelocity = calculateInitialVelocity(startH: startHeight, endH: endHeight)
            let pointInBounce = bounceTimer(currentTime: currentTime)
            let partOne = initialVelocity * pointInBounce
            let partTwo = acceleration * pow(pointInBounce, 2.0)
            var ballY = partOne + partTwo / 2
            if startHeight > 0{
                ballY += Double(startHeight)
            }
            circle.position = CGPoint(x: 0, y: ballY)
        }
    }
    
    func bounceTimer(currentTime: TimeInterval) -> Double{ // Can definitely dry this. 
        if lastLandingTime == 0{
            lastLandingTime = currentTime
        }
        if circle.xScale != 1.0 && ballScaleCooldown <= 0{
            circle.xScale = 1.0
            circle.yScale = 1.0
            circle.fillColor = .black
            circle.strokeColor = .black
        }
        if ballScaleCooldown > 0{
            circle.xScale = 1.5 * CGFloat(ballScaleCooldown) / 7.0
            circle.yScale = 1.5 * CGFloat(ballScaleCooldown) / 7.0
            ballScaleCooldown -= 1
        }
        
        if currentTime >= lastLandingTime + beatDuration{
            lastLandingTime += beatDuration
            circle.xScale = 1.5
            circle.yScale = 1.5
            circle.fillColor = .red
            circle.strokeColor = .red
            ballScaleCooldown = 7
            startHeight = endHeight
            endHeight = nextJumpHeight
            nextJumpHeight = 0.0
        }

        var proportionElapsed: Double = 0.0
        proportionElapsed = (currentTime - lastLandingTime) / beatDuration
        return proportionElapsed
    }
    
}
