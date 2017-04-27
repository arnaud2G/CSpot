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
    
    var btnTop:BtnMedal!
    var btnBottom:BtnMedal!
    var btnConnection:BtnMedal!
    
    var btnCancel:UIButton!
    var btnSend:UIButton!
    
    let largeBtnSize = UIScreen.main.bounds.width*0.5
    let smallBtnSize = UIScreen.main.bounds.width*0.2
    
    enum CSpotShape {
        
        case menu, takePicture, validePicture, describeSpot, searchSpot
        
        func myTopRect(largeBtnSize:CGFloat, smallBtnSize:CGFloat) -> CGRect {
            switch self {
            case .menu:
                let xCenter = (UIScreen.main.bounds.width - largeBtnSize)/2
                let yCenterTop = UIScreen.main.bounds.height/2 - largeBtnSize - 20
                return CGRect(x: xCenter, y: yCenterTop, width: largeBtnSize, height: largeBtnSize)
            case .searchSpot:
                let xCenter = (UIScreen.main.bounds.width)/2
                let yCenterTop = UIScreen.main.bounds.height/2 - 20
                return CGRect(x: xCenter, y: yCenterTop, width: 0, height: 0)
            default:
                let xCenter = (UIScreen.main.bounds.width - largeBtnSize)/2
                let yCenterTop = -largeBtnSize
                return CGRect(x: xCenter, y: yCenterTop, width: largeBtnSize, height: largeBtnSize)
            }
        }
        
        func myBottomRect(largeBtnSize:CGFloat, smallBtnSize:CGFloat) -> CGRect {
            switch self {
            case .menu:
                let xCenter = (UIScreen.main.bounds.width - largeBtnSize)/2
                let yCenterTop = UIScreen.main.bounds.height/2 + 20
                return CGRect(x: xCenter, y: yCenterTop, width: largeBtnSize, height: largeBtnSize)
            case .describeSpot:
                let xCenter = (UIScreen.main.bounds.width)/2
                let yCenterTop = UIScreen.main.bounds.height - (smallBtnSize*1.2/2) - 30.0
                return CGRect(x: xCenter, y: yCenterTop, width: 0, height: 0)
            case .searchSpot:
                let xCenter = (UIScreen.main.bounds.width)/2
                let yCenterTop = UIScreen.main.bounds.height/2 + 20
                return CGRect(x: xCenter, y: yCenterTop, width: 0, height: 0)
            default:
                let xCenter = (UIScreen.main.bounds.width - smallBtnSize*1.2)/2
                let yCenterTop = UIScreen.main.bounds.height - smallBtnSize*1.2 - 30.0
                return CGRect(x: xCenter, y: yCenterTop, width: smallBtnSize*1.2, height: smallBtnSize*1.2)
            }
        }
        
        func mySendRect(smallBtnSize:CGFloat) -> CGRect {
            switch self {
            case .validePicture:
                let xCenter = UIScreen.main.bounds.width - 30 - smallBtnSize
                let yCenterTop = UIScreen.main.bounds.height - 30 - smallBtnSize
                return CGRect(x: xCenter, y: yCenterTop, width: smallBtnSize, height: smallBtnSize)
            default:
                let xCenter = UIScreen.main.bounds.width - 30 - smallBtnSize/2
                let yCenterTop = UIScreen.main.bounds.height - 30 - smallBtnSize/2
                return CGRect(x: xCenter, y: yCenterTop, width: 0, height: 0)
            }
        }
    }
    
    var cSpotShape:Variable<CSpotShape> = Variable(.menu)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSend = UIButton(frame: cSpotShape.value.mySendRect(smallBtnSize: 0))
        btnSend.layer.cornerRadius = btnSend.frame.size.width/2
        btnSend.clipsToBounds = true
        btnSend.selectedStyle()
        btnSend.setImage(#imageLiteral(resourceName: "ship").withRenderingMode(.alwaysTemplate), for: .normal)
        btnSend.addTarget(self, action: #selector(self.validePic(sender:)), for: .touchUpInside)
        self.view.addSubview(btnSend)
        
        btnTop = BtnMedal(frame: cSpotShape.value.myTopRect(largeBtnSize: 0, smallBtnSize: 0))
        btnTop.layer.cornerRadius = btnTop.frame.size.width/2
        btnTop.clipsToBounds = true
        btnTop.unselectedStyle()
        btnTop.setImage(#imageLiteral(resourceName: "treasure-map").withRenderingMode(.alwaysTemplate), for: .normal)
        self.view.addSubview(btnTop)
        observeBtnTop(btnTop: btnTop)
        
        btnBottom = BtnMedal(frame: cSpotShape.value.myBottomRect(largeBtnSize: 0, smallBtnSize: 0))
        btnBottom.layer.cornerRadius = btnTop.frame.size.width/2
        btnBottom.clipsToBounds = true
        btnBottom.unselectedStyle()
        btnBottom.setImage(#imageLiteral(resourceName: "spyglass").withRenderingMode(.alwaysTemplate), for: .normal)
        self.view.addSubview(btnBottom)
        observeBtnBottom(btnBottom: btnBottom)
        
        btnConnection = BtnMedal(frame: cSpotShape.value.myBottomRect(largeBtnSize: 0, smallBtnSize: 0))
        btnConnection.layer.cornerRadius = btnTop.frame.size.width/2
        btnConnection.clipsToBounds = true
        btnConnection.unselectedStyle()
        btnConnection.setImage(#imageLiteral(resourceName: "login").withRenderingMode(.alwaysTemplate), for: .normal)
        btnConnection.addTarget(self, action: #selector(self.connection(sender:)), for: .touchUpInside)
        self.view.addSubview(btnConnection)
        
        btnCancel = UIButton(frame: CGRect(x: 26, y: 26, width: 30, height: 30))
        btnCancel.layer.cornerRadius = btnTop.frame.size.width
        btnCancel.tintColor = UIColor().primary()
        btnCancel.setImage(#imageLiteral(resourceName: "delete").withRenderingMode(.alwaysTemplate), for: .normal)
        btnCancel.addTarget(self, action: #selector(self.cancel(sender:)), for: .touchUpInside)
        self.view.addSubview(btnCancel)
        
        observeCSpotShape()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        btnBottom.medalStyle(image: #imageLiteral(resourceName: "pirate"), text: "Utilise la longue vue pour décrire le spot !", delay: 3)
        btnConnection.medalStyle(image: #imageLiteral(resourceName: "pirate"), text: "Connecte toi pour utiliser la longue vue !", delay: 3)
        btnTop.medalStyle(image: #imageLiteral(resourceName: "pirate"), text: "Utilise la map pour trouver un bon spot !", delay: 6)
    }
    
    func cancel(sender:UIButton) {
        self.cSpotShape.value = .menu
    }
    
    func connection(sender:UIButton) {
        let loginStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
        let loginController = loginStoryboard.instantiateViewController(withIdentifier: "SignIn")
        self.present(loginController, animated: true, completion: nil)
    }
    
    private func observeCSpotShape() {
        
        User.current.connected
            .asObservable()
            .subscribe(onNext:{
                description in
                if description {
                    self.btnBottom.isHidden = false
                    self.btnConnection.isHidden = true
                } else {
                    self.btnBottom.isHidden = true
                    self.btnConnection.isHidden = false
                }
            }).addDisposableTo(disposeBag)
        
        cSpotShape.asObservable()
            .subscribe(onNext:{
                description in
                self.btnBottom.resizeCircle(self.cSpotShape.value.myBottomRect(largeBtnSize: self.largeBtnSize, smallBtnSize: self.smallBtnSize), duration: 0.3)
                self.btnConnection.resizeCircle(self.cSpotShape.value.myBottomRect(largeBtnSize: self.largeBtnSize, smallBtnSize: self.smallBtnSize), duration: 0.3)
                self.btnTop.resizeCircle(self.cSpotShape.value.myTopRect(largeBtnSize: self.largeBtnSize, smallBtnSize: self.smallBtnSize), duration: 0.3)
                self.btnSend.resizeCircle(self.cSpotShape.value.mySendRect(smallBtnSize: self.smallBtnSize), duration: 0.3)
                self.btnCancel.isHidden = description == .menu
                self.btnTop.disabledMedal(disabled: description != .menu)
                self.btnBottom.disabledMedal(disabled: description != .menu)
            }).addDisposableTo(disposeBag)
    }
    
    private func observeBtnBottom(btnBottom:UIButton) {
        btnBottom.rx.tap
            .subscribe(onNext:{
                description in
                switch self.cSpotShape.value {
                case .menu:
                    self.cSpotShape.value = .takePicture
                    Spot.newSpot.reset()
                case .takePicture:
                    self.cSpotShape.value = .validePicture
                    NotificationCenter.default.post(name: CSpotNotif.takePic.name, object: nil)
                case .validePicture:
                    self.cSpotShape.value = .takePicture
                    NotificationCenter.default.post(name: CSpotNotif.retakePic.name, object: nil)
                default:
                    print("Time to rest")
                }
            }).addDisposableTo(disposeBag)
    }
    
    func validePic(sender:UIButton) {
        NotificationCenter.default.post(name: CSpotNotif.validePic.name, object: nil)
        self.cSpotShape.value = .describeSpot
    }
    
    private func observeBtnTop(btnTop:UIButton) {
        btnTop.rx.tap
            .subscribe(onNext:{
                description in
                switch self.cSpotShape.value {
                case .menu:
                    self.cSpotShape.value = .searchSpot
                default:
                    print("Time to rest")
                }
            }).addDisposableTo(disposeBag)
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

