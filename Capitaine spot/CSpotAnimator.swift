//
//  CSpotAnimator.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 11/05/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

class CSPostAnimator: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {
    
    weak var transitionContext: UIViewControllerContextTransitioning!
    
    let lWidth = UIScreen.main.bounds.size.width/2
    let lHeight = UIScreen.main.bounds.size.height/2
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        self.transitionContext = transitionContext
        
        // Animation des chargements
        if transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? LoaddingViewController != nil {
            animatePresentLoadding(using: transitionContext)
            return
        }
        
        if transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? LoaddingViewController != nil {
            animateDismissLoadding(using: transitionContext)
            return
        }
        
        // Animation from/to le menu
        if transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? MenuViewController != nil {
            switch User.current.cSpotScreen.value {
            case .camera, .location, .description:
                animateDismissMenuFromBottom(using: transitionContext)
            case .search, .spot(_):
                animateDismissMenuFromTop(using: transitionContext)
            default:
                fatalError("Ce cas doit être traité")
            }
            return
        }
        
        if transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? MenuViewController != nil {
            switch User.current.cSpotScreen.value {
            case .camera, .location, .description:
                animatePresentMenuFromBottom(using: transitionContext)
            case .search, .spot(_):
                animatePresentMenuFromTop(using: transitionContext)
            default:
                fatalError("Ce cas doit être traité")
            }
            return
        }
        
        // Animation entre les vues de recherche
        if transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? MapSearchController != nil || transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? MapSearchController != nil {
            animatePresentSearch(using: transitionContext)
            return
        }
        
        // Animation vers la map de description
        if transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? DescribeMapViewController != nil {
            animatePresentMap(using: transitionContext)
            return
        }
        
        // Animation vers la description
        if transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? DescriptionViewController != nil {
            animatePresentDescription(using: transitionContext)
            return
        }
        
        fatalError("Cas a traiter")
    }
    
    func animatePresentSearch(using transitionContext: UIViewControllerContextTransitioning) {
        
        // On ajoute la vue
        let containerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! SearchViewController
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! SearchViewController
        containerView.addSubview(toViewController.view)
        
        // On ajoute l'effet
        let circleMaskPathInitial = UIBezierPath(ovalIn: CGRect(origin: fromViewController.transBtn.center, size: CGSize(width: 0, height: 0)))
        let extremePoint = CGPoint(x: fromViewController.transBtn.center.x, y: fromViewController.transBtn.center.y - toViewController.view.bounds.height)
        let radius = sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y))
        let circleMaskPathFinal = UIBezierPath(ovalIn: CGRect(x: 150 - radius, y: 150 - radius, width: 2*radius, height: 2*radius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        toViewController.view.layer.mask = maskLayer
        
        // On défini l'animation
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    private func animatePresentMenuFromBottom(using transitionContext: UIViewControllerContextTransitioning) {
        
        // On ajoute la vue
        let containerView = transitionContext.containerView
        let menuViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! MenuViewController
        let presentedViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        containerView.addSubview(presentedViewController!.view)
        
        // On ajoute l'effet
        let lWidth = UIScreen.main.bounds.size.width/2
        let lHeight = UIScreen.main.bounds.size.height/2
        let rayon = sqrt((lWidth*lWidth)+(lHeight*lHeight))
        let circleMaskPathInitial = UIBezierPath(ovalIn: menuViewController.btnBottom.frame)
        let circleMaskPathFinal = UIBezierPath(ovalIn: CGRect(x: lWidth - rayon, y: lHeight - rayon, width: 2*rayon, height: 2*rayon))
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        presentedViewController!.view.layer.mask = maskLayer
        
        // On défini l'animation
        let maskLayerAnimation = CASpringAnimation(keyPath: "path")
        maskLayerAnimation.damping = 6
        maskLayerAnimation.initialVelocity = 1
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    private func animatePresentMenuFromTop(using transitionContext: UIViewControllerContextTransitioning) {
        
        // On ajoute la vue
        let containerView = transitionContext.containerView
        let menuViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! MenuViewController
        let presentedViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        containerView.addSubview(presentedViewController!.view)
        
        // On ajoute l'effet
        let lWidth = UIScreen.main.bounds.size.width/2
        let lHeight = UIScreen.main.bounds.size.height/2
        let rayon = sqrt((lWidth*lWidth)+(lHeight*lHeight))
        let circleMaskPathInitial = UIBezierPath(ovalIn: menuViewController.btnTop.frame)
        let circleMaskPathFinal = UIBezierPath(ovalIn: CGRect(x: lWidth - rayon, y: lHeight - rayon, width: 2*rayon, height: 2*rayon))
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        presentedViewController!.view.layer.mask = maskLayer
        
        // On défini l'animation
        let maskLayerAnimation = CASpringAnimation(keyPath: "path")
        maskLayerAnimation.damping = 6
        maskLayerAnimation.initialVelocity = 1
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    private func animateDismissMenuFromBottom(using transitionContext: UIViewControllerContextTransitioning) {
        
        // On ajoute la vue
        let containerView = transitionContext.containerView
        for view in containerView.subviews {
            print(view)
        }
        
        let myCamera = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let menuViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! MenuViewController
        containerView.addSubview(menuViewController.view)
        containerView.addSubview(myCamera.view)
        
        //containerView.add
        // On ajoute l'effet
        let lWidth = UIScreen.main.bounds.size.width/2
        let lHeight = UIScreen.main.bounds.size.height/2
        let rayon = sqrt((lWidth*lWidth)+(lHeight*lHeight))
        let circleMaskPathFinal = UIBezierPath(ovalIn: CGRect(origin: menuViewController.btnBottom.center, size: CGSize.zero))
        let circleMaskPathInitial = UIBezierPath(ovalIn: CGRect(x: lWidth - rayon, y: lHeight - rayon, width: 2*rayon, height: 2*rayon))
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        myCamera.view.layer.mask = maskLayer
        
        // On défini l'animation
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)/2
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    private func animateDismissMenuFromTop(using transitionContext: UIViewControllerContextTransitioning) {
        
        // On ajoute la vue
        let containerView = transitionContext.containerView
        for view in containerView.subviews {
            print(view)
        }
        
        let myCamera = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let menuViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! MenuViewController
        containerView.addSubview(menuViewController.view)
        containerView.addSubview(myCamera.view)
        
        //containerView.add
        // On ajoute l'effet
        let lWidth = UIScreen.main.bounds.size.width/2
        let lHeight = UIScreen.main.bounds.size.height/2
        let rayon = sqrt((lWidth*lWidth)+(lHeight*lHeight))
        let circleMaskPathFinal = UIBezierPath(ovalIn: CGRect(origin: menuViewController.btnTop.center, size: CGSize.zero))
        let circleMaskPathInitial = UIBezierPath(ovalIn: CGRect(x: lWidth - rayon, y: lHeight - rayon, width: 2*rayon, height: 2*rayon))
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        myCamera.view.layer.mask = maskLayer
        
        // On défini l'animation
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)/2
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    func animatePresentLoadding(using transitionContext: UIViewControllerContextTransitioning) {
        
        // On ajoute la vue
        let containerView = transitionContext.containerView
        let loaddingViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! LoaddingViewController
        containerView.addSubview(loaddingViewController.view)
        
        // On ajoute l'effet
        let circleMaskPathInitial = UIBezierPath(ovalIn: CGRect(x: 100, y: 100, width: 0, height: 0))
        let circleMaskPathFinal = UIBezierPath(ovalIn: CGRect(x: 100 - 700, y: 100 - 700, width: 1400, height: 1400))
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        loaddingViewController.view.layer.mask = maskLayer
        
        // On défini l'animation
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    func animateDismissLoadding(using transitionContext: UIViewControllerContextTransitioning) {
        
        // On ajoute la vue
        let containerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(fromViewController.view)
        
        // On ajoute l'effet
        let circleMaskPathFinal = UIBezierPath(ovalIn: CGRect(x: 100, y: 100, width: 0, height: 0))
        let circleMaskPathInitial = UIBezierPath(ovalIn: CGRect(x: 100 - 700, y: 100 - 700, width: 1400, height: 1400))
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        fromViewController.view.layer.mask = maskLayer
        
        // On défini l'animation
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    func animatePresentMap(using transitionContext: UIViewControllerContextTransitioning) {
        
        // On ajoute la vue
        let containerView = transitionContext.containerView
        let describeMapViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! DescribeMapViewController
        containerView.addSubview(describeMapViewController.view)
        
        // On ajoute l'effet
        let lWidth = UIScreen.main.bounds.size.width/2
        let lHeight = UIScreen.main.bounds.size.height/2
        let rayon = sqrt((lWidth*lWidth)+(lHeight*lHeight))
        let circleMaskPathInitial = UIBezierPath(ovalIn: CGRect(origin: describeMapViewController.mapView.center, size: CGSize.zero))
        let circleMaskPathFinal = UIBezierPath(ovalIn: CGRect(x: lWidth - rayon, y: lHeight - rayon, width: 2*rayon, height: 2*rayon))
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        describeMapViewController.view.layer.mask = maskLayer
        
        // On défini l'animation
        let maskLayerAnimation = CASpringAnimation(keyPath: "path")
        maskLayerAnimation.damping = 6
        maskLayerAnimation.initialVelocity = 1
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    func animatePresentDescription(using transitionContext: UIViewControllerContextTransitioning) {
        
        // On ajoute la vue
        let containerView = transitionContext.containerView
        let descriptionViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! DescriptionViewController
        containerView.addSubview(descriptionViewController.view)
        
        // On ajoute l'effet
        let lWidth = UIScreen.main.bounds.size.width/2
        let lHeight = UIScreen.main.bounds.size.height/2
        let rayon = sqrt((lWidth*lWidth)+(lHeight*lHeight))
        let circleMaskPathInitial = UIBezierPath(ovalIn: CGRect(origin: descriptionViewController.btnCheck.center, size: CGSize.zero))
        let circleMaskPathFinal = UIBezierPath(ovalIn: CGRect(x: lWidth - rayon, y: lHeight - rayon, width: 2*rayon, height: 2*rayon))
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        descriptionViewController.view.layer.mask = maskLayer
        
        // On défini l'animation
        let maskLayerAnimation = CASpringAnimation(keyPath: "path")
        maskLayerAnimation.damping = 6
        maskLayerAnimation.initialVelocity = 1
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.transitionContext.completeTransition(true)
    }
}
