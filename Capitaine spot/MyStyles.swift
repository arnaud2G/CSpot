//
//  MyStyles.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 10/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

// Couleurs de l'application
extension UIColor {
    
    func colorFromHex(rgbValue:UInt32, alpha:CGFloat=1.0)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    func primary()->UIColor {
        return colorFromHex(rgbValue: 0xCA611A)
    }
    
    func secondary()->UIColor {
        return colorFromHex(rgbValue: 0xFFCA73)
    }
    
    func primaryPopUp()->UIColor {
        return colorFromHex(rgbValue: 0xCA611A, alpha: 0.8)
    }
    
    func secondaryPopUp()->UIColor {
        return colorFromHex(rgbValue: 0xFFCA73, alpha: 0.6)
    }
    
    func popUp()->UIColor {
        return colorFromHex(rgbValue: 0xD2D3D5, alpha: 0.8)
    }
    
    func notification()->UIColor {
        return colorFromHex(rgbValue: 0xFB6265)
    }
}

extension UIView {
    
    func unselectedStyle() {
        
        self.backgroundColor = UIColor().secondary()
        
        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor().primary().cgColor
        
        self.tintColor = UIColor().primary()
        
        self.clipsToBounds = true
        
        if let medal = (self as? UIMedal) {
            medal.text.textColor = UIColor().primary()
        }
        
        if let button = (self as? UIButton) {
            button.setTitleColor(UIColor().primary(), for: .normal)
        }
        
        if let tfView = (self as? UITextField) {
            tfView.textColor = UIColor().primary()
            tfView.textAlignment = .center
        }
        
    }
    
    func selectedStyle() {
        
        self.backgroundColor = UIColor().primary()
        
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor().secondary().cgColor
        
        self.tintColor = UIColor().secondary()
        
        self.clipsToBounds = true
        
        if let medal = (self as? UIMedal) {
            medal.text.textColor = UIColor().secondary()
        }
        
        if let button = (self as? UIButton) {
            button.setTitleColor(UIColor().secondary(), for: .normal)
        }
        
        if let tfView = (self as? UITextField) {
            tfView.textColor = UIColor().secondary()
            tfView.textAlignment = .center
        }
    }
}



