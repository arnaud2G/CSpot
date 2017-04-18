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

class User {

    
    static let current = User()
    
    var location: Variable<CLLocationCoordinate2D>?
    private let locationManager = CLLocationManager()
    
    let disposeBag = DisposeBag()
    
    init() {
        //locationIsEnabled = CLLocationManager.locationServicesEnabled()
    }
    
    func updateLocationEnabled() {
        if CLLocationManager.locationServicesEnabled() {return}
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
    }
    
    func localize() -> Bool {
        
        if CLLocationManager.locationServicesEnabled() {
            
            GeolocationService.instance.location
            .asObservable()
                .subscribe(onNext: {
                    descriptions in
                    print(descriptions)
                }).addDisposableTo(disposeBag)
        }
        
        return CLLocationManager.locationServicesEnabled()
    }
}

