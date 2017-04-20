//
//  CSpotNavigationController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 20/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

class CSpotNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnSize = UIScreen.main.bounds.width*0.5
        let xCenter = (UIScreen.main.bounds.width - btnSize)/2
        let yCenterTop = UIScreen.main.bounds.height/2 - btnSize - 20
        let yCenterBottom = UIScreen.main.bounds.height/2 + 20
        
        let btnTop = UIButton(frame: CGRect(x: xCenter, y: yCenterTop, width: btnSize, height: btnSize))
        btnTop.layer.cornerRadius = btnSize/2
        btnTop.clipsToBounds = true
        btnTop.unselectedStyle()
        self.view.addSubview(btnTop)
        
        let btnBottom = UIButton(frame: CGRect(x: xCenter, y: yCenterBottom, width: btnSize, height: btnSize))
        btnBottom.layer.cornerRadius = btnSize/2
        btnBottom.clipsToBounds = true
        btnTop.unselectedStyle()
        self.view.addSubview(btnBottom)
    }
}

class CSpotViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        User.current.updateLocationEnabled()
        
        let cSpotStoryboard = UIStoryboard(name: "CSpot", bundle: nil)
        let menuViewController = cSpotStoryboard.instantiateViewController(withIdentifier: "MenuViewController")
        
        self.addChildViewController(menuViewController)
        menuViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(menuViewController.view)
        
        self.view.leftAnchor.constraint(equalTo: menuViewController.view.leftAnchor).isActive = true
        self.view.rightAnchor.constraint(equalTo: menuViewController.view.rightAnchor).isActive = true
        self.view.topAnchor.constraint(equalTo: menuViewController.view.topAnchor).isActive = true
        self.view.bottomAnchor.constraint(equalTo: menuViewController.view.bottomAnchor).isActive = true
    }
}


