//
//  DescriptionNavigationController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 21/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

class DescriptionNavigationController:UINavigationController, UINavigationControllerDelegate {
    
    deinit {
        print("deinit DescriptionNavigationController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overCurrentContext
        self.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CircleTransitionAnimator()
    }
    
}

class CircleTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {
    
    weak var transitionContext: UIViewControllerContextTransitioning!
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        //1
        self.transitionContext = transitionContext
        
        //2
        let containerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        //3
        containerView.addSubview(toViewController!.view)
        
        //4
        let circleMaskPathInitial = UIBezierPath(ovalIn: CGRect(x: 100, y: 100, width: 0, height: 0))
        let extremePoint = CGPoint(x: 150, y: 150 - toViewController!.view.bounds.height)
        let radius = sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y))
        
        let circleMaskPathFinal = UIBezierPath(ovalIn: CGRect(x: 150 - 500, y: 150 - 500, width: 1000, height: 1000))
        
        //5
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        toViewController?.view.layer.mask = maskLayer
        
        //6
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)
        maskLayerAnimation.delegate = self as? CAAnimationDelegate
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("Stop")
        self.transitionContext.completeTransition(true)
    }
}
