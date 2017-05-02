//
//  User.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 12/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import Mapbox
import RxCocoa
import RxSwift
import MapKit
import AWSMobileHubHelper

class User {
    
    static let current = User()
    
    static let keyCooX = "CSpot.Spot.cooX"
    static let keyCooY = "CSpot.Spot.cooY"
    
    var location: Variable<CLLocationCoordinate2D?> = Variable(nil)
    private let locationManager = CLLocationManager()
    
    var place: Variable<String?> = Variable(nil)
    let placeCoder = CLGeocoder()
    
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
        
        location.asObservable()
            .subscribe(onNext:{
                coordinate in
                
                guard let coordinate = coordinate else {return}
                
                self.placeCoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), completionHandler: {
                    (placemarks, error) -> Void in
                    
                    if let placemarks = placemarks, let placemark = placemarks.first, let locality = placemark.locality {
                        
                        if let subLocality = placemark.subLocality {
                            self.place.value = "\(locality) \(subLocality)"
                        } else {
                            self.place.value = locality
                        }
                    }
                })
            }).addDisposableTo(disposeBag)
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
                .distinctUntilChanged({
                    val1, val2 -> Bool in
                    return val1.latitude.roundTo(places: 3) == val2.latitude.roundTo(places: 3) && val1.longitude.roundTo(places: 3) == val2.longitude.roundTo(places: 3)
                })
                .debounce(0.3, scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    descriptions in
                    print(descriptions)
                    self.location.value = descriptions
                    self.updateLastCoo(coo:descriptions)
                }).addDisposableTo(disposeBag)
        }
        
        return CLLocationManager.locationServicesEnabled()
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

