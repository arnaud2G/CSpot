//
//  VueC1.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 11/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class VueC1: VueC2 {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Spot.newSpot.reset()
        displayTopScreen()
    }
    
    @IBAction func AnimatePressed(_ sender: Any) {
        
        let vueC2 = SpotLocationViewController()
        vueC2.modalPresentationStyle = .overCurrentContext
        self.present(vueC2, animated: false, completion: nil)
    }
    
    private func displayTopScreen() {
        
        // Position
        let tfSpot = UITextField()
        tfSpot.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tfSpot)
        tfSpot.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        tfSpot.heightAnchor.constraint(equalToConstant: 40).isActive = true
        tfSpot.topAnchor.constraint(equalTo: self.view.topAnchor, constant:40).isActive = true
        
        tfSpot.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant:60).isActive = true
        tfSpot.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant:-60).isActive = true
        
        // Attributes
        tfSpot.layer.cornerRadius = 20
        tfSpot.unselectedStyle()
        tfSpot.isEnabled = false
        
        Spot.newSpot.title.asObservable()
            .subscribe(onNext: {
                description in
                if description == String() {
                    tfSpot.isHidden = true
                } else {
                    tfSpot.text = description
                    tfSpot.isHidden = false
                    self.onTheGround.append(contentsOf: TypeSpot.spot.nextType)
                }
            }).addDisposableTo(disposableBag)
    }
}

/*extension VueC1: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.width/2)
        
        transition.originFrame = CGRect(origin: center, size: CGSize.zero)
        transition.presenting = true
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration    = 5.0
    var presenting  = true
    var originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)-> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        let toView = transitionContext.view(forKey: .to)!
        
        let herbView = presenting ? toView : transitionContext.view(forKey: .from)!
        herbView.layer.cornerRadius = 0
        
        let initialFrame = presenting ? originFrame : herbView.frame
        let finalFrame = presenting ? herbView.frame : originFrame
        
        let xScaleFactor = presenting ?
            initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting ?
            initialFrame.height / finalFrame.height :
            finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        if presenting {
            herbView.transform = scaleTransform
            herbView.center = CGPoint(
                x: initialFrame.midX,
                y: initialFrame.midY)
            herbView.clipsToBounds = true
        }
        
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: herbView)
        
        UIView.animate(withDuration: duration, delay: 0, options: [], animations: {
            
            herbView.transform = self.presenting ? CGAffineTransform.identity : scaleTransform
            
            herbView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }, completion: {
            void in
            transitionContext.completeTransition(true)
        })
        
        let round = CABasicAnimation(keyPath: "cornerRadius")
        round.fromValue = 0.0
        round.toValue = 300
        round.duration = duration
        herbView.layer.add(round, forKey: "cornerRadius")
        herbView.layer.cornerRadius = 300
    }
    
}*/
