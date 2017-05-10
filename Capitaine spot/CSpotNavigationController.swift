//
//  CSpotNavigationController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 10/05/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

enum CSpotScreen {
    case menu, camera, description
}

class CSpotNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    let disposeBag = DisposeBag()
    
    var myCamera:MyCamera?
    
    deinit {
        print("deinit DescriptionNavigationController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        User.current.cSpotScreen.asObservable()
            .subscribe(onNext:{
                [weak self] cSpotScreen in
                switch User.current.cSpotScreen.value {
                case .menu:
                    self?.myCamera = MyCamera()
                case .camera:
                    self?.pushViewController(self!.myCamera!, animated: true)
                case .description:
                    let descriptionStoryboard = UIStoryboard(name: "Description", bundle: nil)
                    let descriptionController = descriptionStoryboard.instantiateInitialViewController()
                    self?.pushViewController(descriptionController!, animated: true)
                }
        }).addDisposableTo(disposeBag)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch User.current.cSpotScreen.value {
        case .camera:
            return MenuToCameraAnimator()
        default:
            return nil
        }
    }
}

class MenuToCameraAnimator: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {
    
    weak var transitionContext: UIViewControllerContextTransitioning!
    
    let lWidth = UIScreen.main.bounds.size.width/2
    let lHeight = UIScreen.main.bounds.size.height/2
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        if transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? MenuViewController == nil {
            animatePresent(using: transitionContext)
        } else {
            animateDismiss(using: transitionContext)
        }
    }
    
    private func animatePresent(using transitionContext: UIViewControllerContextTransitioning) {
    
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
    
    private func animateDismiss(using transitionContext: UIViewControllerContextTransitioning) {
        
        // On ajoute la vue
        let containerView = transitionContext.containerView
        for view in containerView.subviews {
            print(view)
        }
        
        let myCamera = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! MyCamera
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
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.transitionContext.completeTransition(true)
    }
}
