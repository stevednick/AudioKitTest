//
//  SlideInTransition.swift
//  Farkas
//
//  Created by Stephen Nicholls on 16/03/2020.
//  Copyright © 2020 Stephen Nicholls. All rights reserved.
//

import UIKit

class SlideInTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresenting = false
    let dimmingView = UIView()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to), let fromViewController = transitionContext.viewController(forKey: .from) else {return}
        
        let containerView = transitionContext.containerView
        let finalWidth = toViewController.view.bounds.width * 0.5
        let finalHeight = toViewController.view.bounds.height
        
        if isPresenting{
            dimmingView.backgroundColor = .black
            dimmingView.alpha = 0.0
            dimmingView.frame = containerView.bounds
            containerView.addSubview(dimmingView)
            
            containerView.addSubview(toViewController.view)
            
            toViewController.view.frame = CGRect(x: -finalWidth, y: 0, width: finalWidth, height: finalHeight)
        }
        
        let transform = {
            self.dimmingView.alpha = 0.5
            toViewController.view.transform = CGAffineTransform(translationX: finalWidth, y: 0)
        }
        
        let identity = {
            self.dimmingView.alpha = 0.0
            fromViewController.view.transform = .identity
        }
        let duration = transitionDuration(using: transitionContext)
        let isCancelled = transitionContext.transitionWasCancelled
        UIView.animate(withDuration: duration, animations: {
            self.isPresenting ? transform() : identity()
        }, completion: { (_) in 
            transitionContext.completeTransition(!isCancelled)
        })
    }
}
