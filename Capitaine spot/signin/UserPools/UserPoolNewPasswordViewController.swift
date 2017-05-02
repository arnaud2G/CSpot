//
//  UserPoolNewPasswordViewController.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.10
//
//

import Foundation
import AWSCognitoIdentityProvider
import AWSMobileHubHelper

class UserPoolNewPasswordViewController: UIViewController {
    
    var user: AWSCognitoIdentityUser?
    
    @IBOutlet weak var confirmationCode: UITextField!
    @IBOutlet weak var updatedPassword: UITextField!
    
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnBack.setImage(#imageLiteral(resourceName: "delete").withRenderingMode(.alwaysTemplate), for: .normal)
        btnBack.tintColor = UIColor().primary()
        
        btnUpdate.unselectedStyle()
        btnUpdate.setImage(#imageLiteral(resourceName: "pirate").withRenderingMode(.alwaysTemplate), for: .normal)
        btnUpdate.layer.cornerRadius = btnUpdate.frame.size.height/2
    }
    
    
    var popWait:WaitingViewController?
    @IBAction func onUpdatePassword(_ sender: AnyObject) {
        
        popWait = WaitingViewController()
        self.navigationController?.pushViewController(popWait!, animated: true)
        
        guard let confirmationCodeValue = self.confirmationCode.text, !confirmationCodeValue.isEmpty else {
            DispatchQueue.main.async(execute: {
                self.popWait?.setMessageError(error: "Vous devez saisir un mot de passe")
            })
            return
        }
        //confirm forgot password with input from ui.
        _ = self.user?.confirmForgotPassword(confirmationCodeValue, password: self.updatedPassword.text!).continueWith(block: {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    strongSelf.popWait?.setError(error: error)
                } else {
                    strongSelf.popWait?.setMessageError(error: "Le mot de passe a été correctement modifié", toRoot:true)
                }
            })
            return nil
        })
    }
    
    @IBAction func onCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
}
