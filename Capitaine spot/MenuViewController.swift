//
//  ViewController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 07/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import RxSwift
import RxCocoa

class MenuViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    let myCamera = MyCamera()
    
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var vSpot: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnLogout.setImage(#imageLiteral(resourceName: "logout").withRenderingMode(.alwaysTemplate), for: .normal)
        btnLogout.backgroundColor = UIColor().notification()
        btnLogout.tintColor = .white
        btnLogout.layer.cornerRadius = 15
        btnLogout.clipsToBounds = true
        btnLogout.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        
        User.current.connected
            .asObservable()
            .subscribe(onNext:{
                description in
                if description {
                    self.btnLogout.isHidden = false
                } else {
                    self.btnLogout.isHidden = true
                }
            }).addDisposableTo(disposeBag)
        
        (self.navigationController as! CSpotNavigationController).cSpotShape
        .asObservable()
            .subscribe(onNext:{
                description in
                switch description {
                case .menu :
                    if let presented = self.presentedViewController {
                        presented.dismiss(animated: true, completion: nil)
                    }
                case .takePicture :
                    if let presented = self.presentedViewController as? MyCamera {
                        presented.imgView.image = nil
                    } else {
                        self.myCamera.imgView.image = nil
                        self.present(self.myCamera, animated: true, completion: nil)
                    }
                case .describeSpot :
                    if let presented = self.presentedViewController {
                        presented.dismiss(animated: false, completion: {
                            let loginStoryboard = UIStoryboard(name: "Transition", bundle: nil)
                            let loginController = loginStoryboard.instantiateInitialViewController()
                            self.present(loginController!, animated: false, completion: {
                                (self.navigationController as! CSpotNavigationController).cSpotShape.value = .menu
                            })
                        })
                    }
                default :
                    print("Ici on ne fait rien")
                }
                self.btnLogout.isHidden = description != .menu
                self.vSpot.isHidden = description != .describeSpot
            }).addDisposableTo(disposeBag)
        
        Spot.newSpot.picture.asObservable()
            .subscribe(onNext: {
                description in
                self.vSpot.image = description
            }).addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnLogoutPressed(_ sender: Any) {
        
        if (AWSIdentityManager.default().isLoggedIn) {
            AWSIdentityManager.default().logout(completionHandler: {
                (result: Any?, error: Error?) in
                if let error = error {
                    print("error lors de la deconexion : \(error)")
                } else if let result = result {
                    print("retour de la deconnexion : \(result)")
                }
            })
        }
    }
}

