//
//  ErrorView.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 02/05/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

class ErrorView:UIView {
    
    //var completionHandler:(() -> Void)?
    convenience init(message:String, frame:CGRect=CGRect.zero, completionHandler:(() -> Void)?=nil)  {
        self.init(frame: frame)
        
        //self.completionHandler = completionHandler
        
        self.unselectedStyle()
        self.layer.cornerRadius = 10
        
        // Tete du capitain
        let imgCaptain = UIImageView()
        imgCaptain.image = #imageLiteral(resourceName: "pirate").withRenderingMode(.alwaysTemplate)
        imgCaptain.tintColor = UIColor().primary()
        imgCaptain.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imgCaptain)
        
        imgCaptain.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imgCaptain.topAnchor.constraint(equalTo: self.topAnchor, constant:10).isActive = true
        
        // Message d'erreur
        let vMessage = UILabel()
        vMessage.text = message
        vMessage.textColor = UIColor().primary()
        vMessage.numberOfLines = 0
        vMessage.translatesAutoresizingMaskIntoConstraints = false
        vMessage.textAlignment = .center
        self.addSubview(vMessage)
        
        vMessage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        vMessage.topAnchor.constraint(equalTo: imgCaptain.bottomAnchor, constant:10).isActive = true
        vMessage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant:10).isActive = true
        
        // Separation
        let vSep = UIView()
        vSep.translatesAutoresizingMaskIntoConstraints = false
        vSep.backgroundColor = UIColor().primary()
        self.addSubview(vSep)
        
        vSep.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        vSep.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant:10).isActive = true
        vSep.topAnchor.constraint(equalTo: vMessage.bottomAnchor, constant:10).isActive = true
        vSep.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Bouton
        btnOk.setTitleColor(UIColor().primary(), for: .normal)
        btnOk.setTitle("OK", for: .normal)
        btnOk.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(btnOk)
        
        btnOk.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        btnOk.topAnchor.constraint(equalTo: vSep.bottomAnchor, constant:10).isActive = true
        btnOk.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant:-10).isActive = true
    }
    
    let btnOk = UIButton()
    /*func btnOkPressed(sender:UIButton) {
        if let completionHandler = completionHandler {
            completionHandler()
        }
    }*/
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
