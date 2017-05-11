//
//  SearchNavigationController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 26/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

import RxCocoa
import RxSwift

import CoreLocation
import MapKit

class SearchViewController:UIViewController {
    var transRect:CGRect!
    var transBtn:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class SearchNavigationController:UINavigationController, UINavigationControllerDelegate {
    
    deinit {
        print("deinit SearchNavigationController")
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC.isKind(of: SearchViewController.self) && toVC.isKind(of: SearchViewController.self) {
            return SearchTransitionAnimator()
        } else {
            return nil
        }
    }
    
    static let SegueToChangeDisplay = "SegueToChangeDisplay"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        let imgView = UIImageView(frame: CGRect(origin: CGPoint(x: UIScreen.main.bounds.size.width-50, y: UIScreen.main.bounds.size.height-50), size: CGSize(width: 100, height: 100)))
        self.view.addSubview(imgView)
        imgView.contentMode = .scaleAspectFit
        imgView.image = #imageLiteral(resourceName: "spiderweb").withRenderingMode(.alwaysTemplate)
        imgView.tintColor = UIColor().secondary()
        
        let imgView2 = UIImageView(frame: CGRect(origin: CGPoint(x: -50, y: UIScreen.main.bounds.size.height/2), size: CGSize(width: 100, height: 100)))
        self.view.addSubview(imgView2)
        imgView2.contentMode = .scaleAspectFit
        imgView2.image = #imageLiteral(resourceName: "spiderweb").withRenderingMode(.alwaysTemplate)
        imgView2.tintColor = UIColor().secondary()
    }
}

class SearchTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {
    
    weak var transitionContext: UIViewControllerContextTransitioning!
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        //1
        self.transitionContext = transitionContext
        
        //2
        let containerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! SearchViewController
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! SearchViewController
        
        //3
        containerView.addSubview(toViewController.view)
        
        //4
        let circleMaskPathInitial = UIBezierPath(ovalIn: CGRect(origin: fromViewController.transBtn.center, size: CGSize(width: 0, height: 0)))
        
        let extremePoint = CGPoint(x: fromViewController.transBtn.center.x, y: fromViewController.transBtn.center.y - toViewController.view.bounds.height)
        
        let radius = sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y))
        let circleMaskPathFinal = UIBezierPath(ovalIn: CGRect(x: 150 - radius, y: 150 - radius, width: 2*radius, height: 2*radius))
        
        //5
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        toViewController.view.layer.mask = maskLayer
        
        //6
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
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
        print("Stop")
        self.transitionContext.completeTransition(true)
    }
}
