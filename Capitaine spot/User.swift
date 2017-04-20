//
//  User.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 12/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import MapKit
import Mapbox
import AWSMobileHubHelper

class User {
    
    static let current = User()
    
    static let keyCooX = "CSpot.Spot.cooX"
    static let keyCooY = "CSpot.Spot.cooY"
    
    var location: Variable<CLLocationCoordinate2D?> = Variable(nil)
    private let locationManager = CLLocationManager()
    
    var connected:Variable<Bool> = Variable(false)
    
    let disposeBag = DisposeBag()
    
    init() {
        
        self.connected.value = AWSIdentityManager.default().isLoggedIn
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignIn, object: nil, queue: OperationQueue.main, using: {
            (note: Notification) -> Void in
            self.connected.value = true
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignOut, object: nil, queue: OperationQueue.main, using: {
            (note: Notification) -> Void in
            self.connected.value = false
        })
    }
    
    func updateLocationEnabled() {
        if CLLocationManager.locationServicesEnabled() {return}
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func updateLastCoo(coo:CLLocationCoordinate2D) {
        let defaults = UserDefaults.standard
        defaults.set(Double(coo.latitude), forKey: User.keyCooX)
        defaults.set(Double(coo.longitude), forKey: User.keyCooY)
    }
    
    static func getLastCoo() -> CLLocationCoordinate2D? {
        let defaults = UserDefaults.standard
        if let latitude = defaults.value(forKey: User.keyCooX) as? Double, let longitude = defaults.value(forKey: User.keyCooY) as? Double {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return nil
    }
    
    func localize() -> Bool {
        
        if CLLocationManager.locationServicesEnabled() {
            
            GeolocationService.instance.startUpdatingLocation()
            GeolocationService.instance.location
                .asObservable()
                .debounce(0.5, scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    descriptions in
                    self.location.value = descriptions
                    self.updateLastCoo(coo:descriptions)
                    GeolocationService.instance.stopUpdatingLocation()
                }).addDisposableTo(disposeBag)
        }
        
        return CLLocationManager.locationServicesEnabled()
    }
}

