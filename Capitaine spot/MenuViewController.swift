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

class MenuViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var lblT1: UILabel!
    @IBOutlet weak var lblT2: UILabel!
    @IBOutlet weak var lblT3: UILabel!
    
    @IBOutlet weak var btnLogout: UIButton!
    
    @IBOutlet weak var btnTop: BtnMedal!
    @IBOutlet weak var btnBottom: BtnMedal!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "woodtexture"))
        
        btnLogout.setImage(#imageLiteral(resourceName: "skull").withRenderingMode(.alwaysTemplate), for: .normal)
        btnLogout.selectedStyle()
        btnLogout.layer.cornerRadius = 15
        
        lblT1.textColor = UIColor().secondary()
        lblT2.textColor = UIColor().secondary()
        lblT3.textColor = UIColor().secondary()
        
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
        
        btnTop.layer.cornerRadius = btnTop.frame.height/2
        btnTop.clipsToBounds = true
        btnTop.unselectedStyle()
        btnTop.setImage(#imageLiteral(resourceName: "treasure-map").withRenderingMode(.alwaysTemplate), for: .normal)
        
        btnBottom.layer.cornerRadius = btnBottom.frame.height/2
        btnBottom.clipsToBounds = true
        btnBottom.unselectedStyle()
        
        User.current.connected
            .asObservable()
            .subscribe(onNext:{
                description in
                if description {
                    self.btnBottom.setImage(#imageLiteral(resourceName: "spyglass").withRenderingMode(.alwaysTemplate), for: .normal)
                } else {
                    self.btnBottom.setImage(#imageLiteral(resourceName: "pirate").withRenderingMode(.alwaysTemplate), for: .normal)
                }
            }).addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        User.current.cSpotScreen.value = .menu
        if User.current.connected.value {
            btnBottom.medalStyle(image: #imageLiteral(resourceName: "pirate"), text: "Utilise la longue vue pour décrire le spot !", delay: 1.5)
        } else {
            btnBottom.medalStyle(image: #imageLiteral(resourceName: "pirate"), text: "Connecte toi pour utiliser la longue vue !", delay: 1.5)
        }
        btnTop.medalStyle(image: #imageLiteral(resourceName: "pirate"), text: "Utilise la map pour trouver un bon spot !", delay:3.5)
    }
    
    @IBAction func btnTopPressed(_ sender: Any) {
        let loginStoryboard = UIStoryboard(name: "Search", bundle: nil)
        let loginController = loginStoryboard.instantiateInitialViewController()
        present(loginController!, animated: false)
    }
    
    @IBAction func btnBottomPressed(_ sender: Any) {
        if User.current.connected.value {
            User.current.cSpotScreen.value = .camera
        } else {
            let loginStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
            let loginController = loginStoryboard.instantiateInitialViewController()
            present(loginController!, animated: true, completion: nil)
        }
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

