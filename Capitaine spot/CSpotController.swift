//
//  CSpotNavigationController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 20/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class CSpotNavigationController: UINavigationController {
    
    let disposeBag = DisposeBag()
    
    var btnTop:UIButton!
    var btnBottom:UIButton!
    
    var btnCancel:UIButton!
    var btnRetry:UIButton!
    
    let largeBtnSize = UIScreen.main.bounds.width*0.5
    let smallBtnSize = UIScreen.main.bounds.width*0.2
    
    enum CSpotShape {
        
        case menu, takePicture, validePicture, describeSpot
        
        func myTopRect(largeBtnSize:CGFloat, smallBtnSize:CGFloat) -> CGRect {
            switch self {
            case .menu:
                let xCenter = (UIScreen.main.bounds.width - largeBtnSize)/2
                let yCenterTop = UIScreen.main.bounds.height/2 - largeBtnSize - 20
                return CGRect(x: xCenter, y: yCenterTop, width: largeBtnSize, height: largeBtnSize)
            case .takePicture:
                let xCenter = (UIScreen.main.bounds.width - largeBtnSize)/2
                let yCenterTop:CGFloat = -largeBtnSize
                return CGRect(x: xCenter, y: yCenterTop, width: largeBtnSize, height: largeBtnSize)
            case .validePicture:
                let xCenter = (UIScreen.main.bounds.width - largeBtnSize)/2
                let yCenterTop:CGFloat = -largeBtnSize
                return CGRect(x: xCenter, y: yCenterTop, width: largeBtnSize, height: largeBtnSize)
            case .describeSpot:
                let xCenter = (UIScreen.main.bounds.width - largeBtnSize)/2
                let yCenterTop:CGFloat = -largeBtnSize
                return CGRect(x: xCenter, y: yCenterTop, width: largeBtnSize, height: largeBtnSize)
            }
        }
        
        func myBottomRect(largeBtnSize:CGFloat, smallBtnSize:CGFloat) -> CGRect {
            switch self {
            case .menu:
                let xCenter = (UIScreen.main.bounds.width - largeBtnSize)/2
                let yCenterTop = UIScreen.main.bounds.height/2 + 20
                return CGRect(x: xCenter, y: yCenterTop, width: largeBtnSize, height: largeBtnSize)
            case .takePicture:
                let xCenter = (UIScreen.main.bounds.width - smallBtnSize)/2
                let yCenterTop:CGFloat = UIScreen.main.bounds.height - smallBtnSize - 30.0
                return CGRect(x: xCenter, y: yCenterTop, width: smallBtnSize, height: smallBtnSize)
            case .validePicture:
                let xCenter = UIScreen.main.bounds.width - smallBtnSize - 30.0
                let yCenterTop:CGFloat = UIScreen.main.bounds.height - smallBtnSize - 30.0
                return CGRect(x: xCenter, y: yCenterTop, width: smallBtnSize, height: smallBtnSize)
            case .describeSpot:
                let xCenter = UIScreen.main.bounds.width - smallBtnSize - 30.0
                let yCenterTop:CGFloat = UIScreen.main.bounds.height - smallBtnSize - 30.0
                return CGRect(x: xCenter, y: yCenterTop, width: smallBtnSize, height: smallBtnSize)
            }
        }
    }
    
    var cSpotShape:Variable<CSpotShape> = Variable(.menu)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnTop = UIButton(frame: cSpotShape.value.myTopRect(largeBtnSize: 0, smallBtnSize: 0))
        btnTop.layer.cornerRadius = largeBtnSize/2
        btnTop.clipsToBounds = true
        btnTop.unselectedStyle()
        btnTop.setImage(#imageLiteral(resourceName: "treasure-map").withRenderingMode(.alwaysTemplate), for: .normal)
        self.view.addSubview(btnTop)
        observeBtnTop(btnTop: btnTop)
        
        btnBottom = UIButton(frame: cSpotShape.value.myBottomRect(largeBtnSize: 0, smallBtnSize: 0))
        btnBottom.layer.cornerRadius = largeBtnSize/2
        btnBottom.clipsToBounds = true
        btnBottom.unselectedStyle()
        btnBottom.setImage(#imageLiteral(resourceName: "spyglass").withRenderingMode(.alwaysTemplate), for: .normal)
        self.view.addSubview(btnBottom)
        observeBtnBottom(btnBottom: btnBottom)
        
        btnCancel = UIButton(frame: CGRect(x: 26, y: 26, width: 30, height: 30))
        btnCancel.layer.cornerRadius = 15
        btnCancel.tintColor = UIColor().primary()
        btnCancel.setImage(#imageLiteral(resourceName: "delete").withRenderingMode(.alwaysTemplate), for: .normal)
        btnCancel.addTarget(self, action: #selector(self.cancel(sender:)), for: .touchUpInside)
        self.view.addSubview(btnCancel)
        
        observeCSpotShape()
    }
    
    func cancel(sender:UIButton) {
        self.cSpotShape.value = .menu
    }
    
    private func observeCSpotShape() {
        cSpotShape.asObservable()
            .subscribe(onNext:{
                description in
                self.btnBottom.resizeCircle(self.cSpotShape.value.myBottomRect(largeBtnSize: self.largeBtnSize, smallBtnSize: self.smallBtnSize), duration: 0.3)
                self.btnTop.resizeCircle(self.cSpotShape.value.myTopRect(largeBtnSize: self.largeBtnSize, smallBtnSize: self.smallBtnSize), duration: 0.3)
                self.btnCancel.isHidden = description == .menu
            }).addDisposableTo(disposeBag)
    }
    
    private func observeBtnBottom(btnBottom:UIButton) {
        btnBottom.rx.tap
            .subscribe(onNext:{
                description in
                switch self.cSpotShape.value {
                case .menu:
                    self.cSpotShape.value = .takePicture
                case .takePicture:
                    self.cSpotShape.value = .validePicture
                    NotificationCenter.default.post(name: CSpotNotif.takePic.name, object: nil)
                case .validePicture:
                    self.cSpotShape.value = .describeSpot
                    NotificationCenter.default.post(name: CSpotNotif.validePic.name, object: nil)
                case .describeSpot:
                    print("Time to describe")
                }
            }).addDisposableTo(disposeBag)
    }
    
    private func observeBtnTop(btnTop:UIButton) {
        
    }
}

class CSpotViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    var menuViewController:MenuViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cSpotStoryboard = UIStoryboard(name: "CSpot", bundle: nil)
        menuViewController = cSpotStoryboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        self.addChildViewController(menuViewController)
        menuViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(menuViewController.view)
        
        self.view.leftAnchor.constraint(equalTo: menuViewController.view.leftAnchor).isActive = true
        self.view.rightAnchor.constraint(equalTo: menuViewController.view.rightAnchor).isActive = true
        self.view.topAnchor.constraint(equalTo: menuViewController.view.topAnchor).isActive = true
        self.view.bottomAnchor.constraint(equalTo: menuViewController.view.bottomAnchor).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !User.current.localize() {
            User.current.updateLocationEnabled()
        }
    }
}


