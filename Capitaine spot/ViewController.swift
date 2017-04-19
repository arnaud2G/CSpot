//
//  ViewController.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 07/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class ViewController: UIViewController {
    
    var signOutObserver: AnyObject!
    var signInObserver: AnyObject!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        signInObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignIn, object: nil, queue: OperationQueue.main, using: {
            (note: Notification) -> Void in
            //guard let strongSelf = self else { return }
            print("Sign In Observer observed sign in.")
        })
        
        signOutObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignOut, object: AWSIdentityManager.default(), queue: OperationQueue.main, using: {
            [weak self](note: Notification) -> Void in
            // guard let strongSelf = self else { return }
            print("Sign Out Observer observed sign out.")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func ConnexionPressed(_ sender: Any) {
        print("Handling optional sign-in.")
        let loginStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
        let loginController = loginStoryboard.instantiateViewController(withIdentifier: "SignIn")
        navigationController?.pushViewController(loginController, animated: true)
    }

}

