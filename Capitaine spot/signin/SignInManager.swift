//
//  SignInManager.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 02/05/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import AWSDynamoDB
import AWSCognitoIdentityProvider

enum AWSNotif: String, NotificationName {
    case userAndPasswordError
}

class SignInManager {
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AnyObject>?
    
    static let main = SignInManager()
    
    func handleCustomSignIn(username:String?, password:String?) {
        // set the interactive auth delegate to self, since this view controller handles the login process for user pools
        AWSCognitoUserPoolsSignInProvider.sharedInstance().setInteractiveAuthDelegate(self)
        self.signInWithUserPool(AWSCognitoUserPoolsSignInProvider.sharedInstance())
    }
    
    func signInWithUserPool(username:String?, password:String?) {
        
        guard let username = username, !username.isEmpty, let password = password, !password.isEmpty else {
            
            NotificationCenter.default.post(name: AWSNotif.userAndPasswordError.name, object: nil)
            return
        }
        // set the task completion result as an object of AWSCognitoIdentityPasswordAuthenticationDetails with username and password that the app user provides
        self.passwordAuthenticationCompletion?.set(result: AWSCognitoIdentityPasswordAuthenticationDetails(username: username, password: password))
    }
}
