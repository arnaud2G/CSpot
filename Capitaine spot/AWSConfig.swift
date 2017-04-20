//
//  AWSConfig.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 19/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import AWSCore

import Foundation
import UIKit
import AWSCore
import AWSMobileHubHelper

// Cognito User Pools Identity Id
let AWSCognitoUserPoolId: String = "us-east-1_VTQzPSY6n"

// Cognito User Pools App Client Id
let AWSCognitoUserPoolAppClientId: String = "45amdk4kuvj6qttconq3vkm59f"

// Cognito User Pools Region
let AWSCognitoUserPoolRegion: AWSRegionType = .USEast1

// Cognito User Pools Client Secret
let AWSCognitoUserPoolClientSecret: String = "15e9uehq3n0rne3nl68g1sht6ov8q9hnlkmkh5bvmom4lp8c4t8t"

/**
 * AWSMobileClient is a singleton that bootstraps the app. It creates an identity manager to establish the user identity with Amazon Cognito.
 */
class AWSMobileClient: NSObject {
    
    // Shared instance of this class
    static let sharedInstance = AWSMobileClient()
    fileprivate var isInitialized: Bool
    //Used for checking whether Push Notification is enabled in Amazon Pinpoint
    static let remoteNotificationKey = "RemoteNotification"
    fileprivate override init() {
        isInitialized = false
        super.init()
    }
    
    deinit {
        // Should never be called
        print("Mobile Client deinitialized. This should not happen.")
    }
    
    /**
     * Configure third-party services from application delegate with url, application
     * that called this provider, and any annotation info.
     *
     * - parameter application: instance from application delegate.
     * - parameter url: called from application delegate.
     * - parameter sourceApplication: that triggered this call.
     * - parameter annotation: from application delegate.
     * - returns: true if call was handled by this component
     */
    func withApplication(_ application: UIApplication, withURL url: URL, withSourceApplication sourceApplication: String?, withAnnotation annotation: Any) -> Bool {
        print("withApplication:withURL")
        AWSIdentityManager.default().interceptApplication(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        if (!isInitialized) {
            isInitialized = true
        }
        
        return false;
    }
    
    /**
     * Performs any additional activation steps required of the third party services
     * e.g. Facebook
     *
     * - parameter application: from application delegate.
     */
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive:")
    }
    
    
    /**
     * Configures all the enabled AWS services from application delegate with options.
     *
     * - parameter application: instance from application delegate.
     * - parameter launchOptions: from application delegate.
     */
    func didFinishLaunching(_ application: UIApplication, withOptions launchOptions: [AnyHashable: Any]?) -> Bool {
        print("didFinishLaunching:")
        
        // Register the sign in provider instances with their unique identifier
        AWSSignInProviderFactory.sharedInstance().register(signInProvider: AWSFacebookSignInProvider.sharedInstance(), forKey: AWSFacebookSignInProviderKey)
        
        // set up cognito user pool
        setupUserPool()
        
        
        let didFinishLaunching: Bool = AWSIdentityManager.default().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
        
        if (!isInitialized) {
            AWSIdentityManager.default().resumeSession(completionHandler: { (result: Any?, error: Error?) in
                print("Connect user \(AWSIdentityManager.default().userName)")
                //print("Result: \(result) Error:\(error)")
            }) // If you get an EXC_BAD_ACCESS here in iOS Simulator, then do Simulator -> "Reset Content and Settings..."
            // This will clear bad auth tokens stored by other apps with the same bundle ID.
            isInitialized = true
        }
        
        return didFinishLaunching
    }
    
    func setupUserPool() {
        AWSCognitoUserPoolsSignInProvider.setupUserPool(withId: AWSCognitoUserPoolId, cognitoIdentityUserPoolAppClientId: AWSCognitoUserPoolAppClientId, cognitoIdentityUserPoolAppClientSecret: AWSCognitoUserPoolClientSecret, region: AWSCognitoUserPoolRegion)
        
        AWSSignInProviderFactory.sharedInstance().register(signInProvider: AWSCognitoUserPoolsSignInProvider.sharedInstance(), forKey:AWSCognitoUserPoolsSignInProviderKey)
    }
}
