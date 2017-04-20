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
    
    @IBOutlet weak var btnLogout: UIButton!
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
                } else {
                    print("retour de la deconnexion : \(result)")
                }
            })
        }
    }
    
    /*func addPressed(_ sender: Any) {
        if User.current.connected.value {
            let loginStoryboard = UIStoryboard(name: "Transition", bundle: nil)
            let loginController = loginStoryboard.instantiateInitialViewController()
            self.present(loginController!, animated: true, completion: nil)
        } else {
            let loginStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
            let loginController = loginStoryboard.instantiateViewController(withIdentifier: "SignIn")
            self.navigationController?.pushViewController(loginController, animated: true)
        }
    }*/
}

