//
//  WaitingViewController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 21/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

class WaitingViewController:UIViewController, CAAnimationDelegate {
    
    deinit {
        print("deinit WaitingViewController")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(message: NSLocalizedString("Chargement...", comment: "Chargement..."))
    }
    
    convenience init(message:String = NSLocalizedString("Chargement...", comment: "Chargement...")) {
        self.init(nibName: nil, bundle: nil)
        
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overCurrentContext
        
        self.view.backgroundColor = UIColor().primary()
        
        let lblWait = UILabel()
        lblWait.text = message
        lblWait.translatesAutoresizingMaskIntoConstraints = false
        lblWait.textColor = UIColor().secondary()
        
        self.view.addSubview(lblWait)
        
        lblWait.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        lblWait.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        sendShip()
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.sendShip), userInfo: nil, repeats: true)
    }
    
    let maskLayerAnimation = CABasicAnimation(keyPath: "path")
    func circleDismiss() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
    
            //DispatchQueue.main.async {
            //}
            
            let circleMaskPathInitial = UIBezierPath(ovalIn: CGRect(x: 150 - 500, y: 150 - 500, width: 1000, height: 1000))
            let circleMaskPathFinal = UIBezierPath(ovalIn: CGRect(x: 100, y: 100, width: 0, height: 0))
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = circleMaskPathFinal.cgPath
            self.view.layer.mask = maskLayer
            
            self.maskLayerAnimation.delegate = self
            self.maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
            self.maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
            self.maskLayerAnimation.duration = 0.5
            maskLayer.add(self.maskLayerAnimation, forKey: "path")
        })
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        maskLayerAnimation.delegate = nil
        self.navigationController?.dismiss(animated: false, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func sendShip() {
        
        let y1 = Double.random(min: 100, max: Double(UIScreen.main.bounds.size.height) - 100)
        let x1 = -60.0
        let y2 = Double.random(min: 100, max: Double(UIScreen.main.bounds.size.height) - 100)
        let x2 = Double(UIScreen.main.bounds.size.width) + 60
        
        
        let a = (y2 - y1)/(x2 - x1)
        let b = y1 - a*x1
        
        let xA = Double(UIScreen.main.bounds.width) / 3
        let xB = 2 * Double(UIScreen.main.bounds.width) / 3
        
        var yA = xA*a + b
        var yB = xB*a + b
        
        //yA = Double.random(min: yA - 100.0, max: yA + 100.0)
        //yB = Double.random(min: yB - 100.0, max: yB + 100.0)
        
        let offSet = Double.random(min: -200.0, max: 200.0)
        yA = yA + offSet
        yB = yB - offSet
        
        // first set up an object to animate
        // we'll use a familiar red square
        let square = UIImageView()
        square.frame = CGRect(x: x1, y: y1, width: 60, height: 60)
        square.image = #imageLiteral(resourceName: "ship").withRenderingMode(.alwaysTemplate)
        square.tintColor = UIColor().secondary()
        
        // add the square to the screen
        self.view.addSubview(square)
        
        // now create a bezier path that defines our curve
        // the animation function needs the curve defined as a CGPath
        // but these are more difficult to work with, so instead
        // we'll create a UIBezierPath, and then create a
        // CGPath from the bezier when we need it
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x1,y: y1))
        path.addCurve(to: CGPoint(x: x2, y: y2), controlPoint1: CGPoint(x: xA, y: yA), controlPoint2: CGPoint(x: xB, y: yB))
        
        // create a new CAKeyframeAnimation that animates the objects position
        let anim = CAKeyframeAnimation(keyPath: "position")
        
        // set the animations path to our bezier curve
        anim.path = path.cgPath
        
        // set some more parameters for the animation
        // this rotation mode means that our object will rotate so that it's parallel to whatever point it is currently on the curve
        anim.rotationMode = kCAAnimationRotateAuto
        //anim.repeatCount = Float.infinity
        anim.duration = 5.0
        
        // we add the animation to the squares 'layer' property
        square.layer.add(anim, forKey: "animate position along path")
    }
    
    
}
