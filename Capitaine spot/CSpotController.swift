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
    var btnSend:UIButton!
    
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
        
        btnTop = UIButton(frame: cSpotShape.value.myTopRect(largeBtnSize: 0, smallBtnSize: 0))
        btnTop.layer.cornerRadius = btnTop.frame.size.width/2
        btnTop.clipsToBounds = true
        btnTop.unselectedStyle()
        btnTop.setImage(#imageLiteral(resourceName: "treasure-map").withRenderingMode(.alwaysTemplate), for: .normal)
        self.view.addSubview(btnTop)
        observeBtnTop(btnTop: btnTop)
        
        btnBottom = UIButton(frame: cSpotShape.value.myBottomRect(largeBtnSize: 0, smallBtnSize: 0))
        btnBottom.layer.cornerRadius = btnTop.frame.size.width/2
        btnBottom.clipsToBounds = true
        btnBottom.unselectedStyle()
        btnBottom.setImage(#imageLiteral(resourceName: "spyglass").withRenderingMode(.alwaysTemplate), for: .normal)
        self.view.addSubview(btnBottom)
        observeBtnBottom(btnBottom: btnBottom)
        
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
        tutoDescription()
        tutoRecherche()
    }
    
    private func tutoDescription() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: {
            timer in
            
            if self.cSpotShape.value != .menu {return}
            
            UIView.transition(with: self.btnBottom, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                
                self.btnBottom.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.btnBottom.frame.size.width/2 - UIImage(named: "pirate")!.size.width/2, bottom: self.btnBottom.frame.size.height/2, right: 0)
                
                self.btnBottom.titleEdgeInsets = UIEdgeInsets(top: 0, left: -UIImage(named: "pirate")!.size.width/2, bottom: -10, right: UIImage(named: "pirate")!.size.width/2)
                
                self.btnBottom.titleLabel?.textAlignment = .center
                self.btnBottom.titleLabel?.font = self.btnBottom.titleLabel?.font.withSize(20)
                
                self.btnBottom.isEnabled = false
                
                self.btnBottom.setImage(#imageLiteral(resourceName: "pirate").withRenderingMode(.alwaysTemplate), for: .normal)
                self.btnBottom.setTitle("Utilise la longue vue pour décrire le spot !", for: .normal)
                self.btnBottom.titleLabel?.numberOfLines = 0
            }) {
                ret in
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {
                    timer in
                    
                    if self.cSpotShape.value != .menu {return}
                    
                    UIView.transition(with: self.btnBottom, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                        
                        self.btnBottom.imageEdgeInsets = UIEdgeInsets.zero
                        self.btnBottom.titleEdgeInsets = UIEdgeInsets.zero
                        
                        self.btnBottom.isEnabled = true
                        
                        self.btnBottom.setImage(#imageLiteral(resourceName: "spyglass").withRenderingMode(.alwaysTemplate), for: .normal)
                        self.btnBottom.setTitle(nil, for: .normal)
                    })
                })
            }
        })
    }
    
    private func tutoRecherche() {
        Timer.scheduledTimer(withTimeInterval: 6, repeats: false, block: {
            timer in
            
            if self.cSpotShape.value != .menu {return}
            
            UIView.transition(with: self.btnTop, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                
                self.btnTop.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.btnTop.frame.size.width/2 - UIImage(named: "pirate")!.size.width/2, bottom: self.btnTop.frame.size.height/2, right: 0)
                
                self.btnTop.titleEdgeInsets = UIEdgeInsets(top: 0, left: -UIImage(named: "pirate")!.size.width/2, bottom: -10, right: UIImage(named: "pirate")!.size.width/2)
                
                self.btnTop.titleLabel?.textAlignment = .center
                self.btnTop.titleLabel?.font = self.btnTop.titleLabel?.font.withSize(20)
                
                self.btnTop.isEnabled = false
                
                self.btnTop.setImage(#imageLiteral(resourceName: "pirate").withRenderingMode(.alwaysTemplate), for: .normal)
                self.btnTop.setTitle("Utilise la map pour trouver un bon spot !", for: .normal)
                self.btnTop.titleLabel?.numberOfLines = 0
            }) {
                ret in
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {
                    timer in
                    
                    if self.cSpotShape.value != .menu {return}
                    
                    UIView.transition(with: self.btnTop, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                        
                        self.btnTop.imageEdgeInsets = UIEdgeInsets.zero
                        self.btnTop.titleEdgeInsets = UIEdgeInsets.zero
                        
                        self.btnTop.isEnabled = true
                        
                        self.btnTop.setImage(#imageLiteral(resourceName: "treasure-map").withRenderingMode(.alwaysTemplate), for: .normal)
                        self.btnTop.setTitle(nil, for: .normal)
                    })
                })
            }
        })
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
                self.btnSend.resizeCircle(self.cSpotShape.value.mySendRect(smallBtnSize: self.smallBtnSize), duration: 0.3)
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
                    Spot.newSpot.reset()
                case .takePicture:
                    self.cSpotShape.value = .validePicture
                    NotificationCenter.default.post(name: CSpotNotif.takePic.name, object: nil)
                case .validePicture:
                    self.cSpotShape.value = .takePicture
                    NotificationCenter.default.post(name: CSpotNotif.retakePic.name, object: nil)
                case .describeSpot:
                    print("Time to describe")
                }
            }).addDisposableTo(disposeBag)
    }
    
    func validePic(sender:UIButton) {
        NotificationCenter.default.post(name: CSpotNotif.validePic.name, object: nil)
        self.cSpotShape.value = .describeSpot
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

