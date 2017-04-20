//
//  AnimateExtension.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 18/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func resizeCircle (summand: CGFloat) {
        
        if summand == 0 {
            self.frame.origin.x -= -1*self.frame.size.width/2
            self.frame.origin.y -= -1*self.frame.size.height/2
            
            self.frame.size.height = summand
            self.frame.size.width = summand
        } else {
            self.frame.origin.x -= summand/2
            self.frame.origin.y -= summand/2
            
            self.frame.size.height += summand
            self.frame.size.width += summand
        }
    }
    
    func animateChangingCornerRadius (toValue: Any?, duration: TimeInterval, delay:TimeInterval=0.0) {
        
        let animation = CABasicAnimation(keyPath:"cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.beginTime = CACurrentMediaTime() + delay
        animation.fromValue = self.layer.cornerRadius
        animation.toValue =  toValue
        animation.duration = duration
        self.layer.cornerRadius = self.frame.size.width/2
        self.layer.add(animation, forKey:"cornerRadius")
    }
    
    func circlePulseAinmation(_ summand: CGFloat, duration: TimeInterval, delay:TimeInterval=0.0, completionBlock:@escaping ()->()) {
        
        UIView.animate(withDuration: duration, delay: delay,  options: .curveEaseInOut, animations: {
            self.resizeCircle(summand: summand)
        }) { _ in
            completionBlock()
        }
        animateChangingCornerRadius(toValue: self.frame.size.width/2, duration: duration, delay: delay)
    }
    
    func resizeCircleWithPulseAinmation(_ summand: CGFloat,  duration: TimeInterval, delay:TimeInterval=0.0, completionHandler: (() -> ())? = nil) {
        
        circlePulseAinmation(summand, duration:duration) {
            if let completionHandler = completionHandler {
                completionHandler()
            }
        }
    }
    
    func resizeCircle(_ nextRect: CGRect,  duration: TimeInterval, delay:TimeInterval=0.0, completionHandler: (() -> ())? = nil) {
        
        UIView.animate(withDuration: duration, delay: delay,  options: .curveEaseInOut, animations: {
            self.frame = nextRect
        }) { _ in
            if let completionHandler = completionHandler {
                completionHandler()
            }
        }
        animateChangingCornerRadius(toValue: nextRect.width/2, duration: duration, delay: delay)
    }
    
    func animAppear(withDuration duration:TimeInterval, delay:TimeInterval, completionBlock:@escaping ()->()) {
        
        UIView.animate(withDuration: duration, delay: delay,  options: .curveEaseInOut, animations: {
            self.alpha = 1.0
        }) { _ in
            self.isUserInteractionEnabled = true
            completionBlock()
        }
        
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = NSNumber(value: 1.5)
        animation.beginTime = CACurrentMediaTime() + delay
        animation.duration = duration
        animation.repeatCount = 1.0
        animation.autoreverses = true
        self.layer.add(animation, forKey: nil)
    }
    
    func animDisappear(withDuration duration:TimeInterval, delay:TimeInterval, completionBlock:@escaping ()->()) {
        
        UIView.animate(withDuration: duration, delay: delay,  options: .curveEaseInOut, animations: {
            self.alpha = 0.0
        }) { _ in
            self.isUserInteractionEnabled = false
            completionBlock()
        }
        
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = NSNumber(value: 0.8)
        animation.beginTime = CACurrentMediaTime() + delay
        animation.duration = duration
        animation.repeatCount = 1.0
        animation.autoreverses = true
        self.layer.add(animation, forKey: nil)
    }
    
    func animSelect(withDuration duration:TimeInterval) {
        
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = NSNumber(value: 1.5)
        animation.duration = duration
        animation.repeatCount = 1.0
        animation.autoreverses = true
        self.layer.add(animation, forKey: nil)
    }
    
    func leaveAndRemove(withDuration duration:TimeInterval, toPoint point:CGPoint) {
        
        UIView.animate(withDuration: duration, delay: 0.0,  options: .curveEaseInOut, animations: {
            self.frame.origin = point
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

