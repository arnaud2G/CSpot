//
//  Spot.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 10/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import MapKit
import MapboxGeocoder

enum TypeSpot: String {
    
    case spot,
    bar, resto,
    biere, cocktail, vin, cafe,
    viande, vegie, poisson, tapas,
    enAmoureux, entreAmis, enFamille, entreCollegue,
    discuter, danser, flechettes
    
    var localizedString: String {
        return NSLocalizedString(self.rawValue, comment: self.rawValue)
    }
    
    var pic:UIImage? {
        if let image = UIImage(named: self.rawValue) {
            return image
        } else {
            return nil
        }
    }
    
    var nextType:[TypeSpot] {
        switch self {
        case .spot:
            return [.resto, .bar]
        case .resto:
            return [.viande, .vegie, .poisson, .tapas]
        case .bar:
            return [.biere, .cocktail, .vin, .cafe]
        case .biere, .cocktail, .vin, .viande, .vegie, .poisson, .tapas, .cafe:
            return [.entreAmis, .enFamille, .entreCollegue, .enAmoureux]
        case .entreAmis, .enFamille, .entreCollegue, .enAmoureux:
            return [.discuter, .danser, .flechettes]
        default:
            return [TypeSpot]()
        }
    }
}

class Spot {
    
    static let newSpot = Spot()
    
    static let keyCooX = "CSpot.Spot.cooX"
    static let keyCooY = "CSpot.Spot.cooY"
    
    var descriptions: Variable<[TypeSpot]> = Variable([])
    var title: Variable<String> = Variable(String())
    var adress:String = String() //
    
    var coordinate: Variable<CLLocationCoordinate2D?> = Variable(nil)
    
    var picture:UIImage? = nil
    var place:String? = nil //
    
    let disposeBag = DisposeBag()
    
    init() {
        coordinate.asObservable()
            .filter{$0 != nil}
            .subscribe(onNext: {
                coo in
                self.updateLastCoo(coo:coo!)
                self.searchClosestState(newCoordinate: coo!)
            }).addDisposableTo(disposeBag)
    }
    
    private func updateLastCoo(coo:CLLocationCoordinate2D) {
        let defaults = UserDefaults.standard
        defaults.set(Double(coo.latitude), forKey: Spot.keyCooX)
        defaults.set(Double(coo.longitude), forKey: Spot.keyCooY)
    }
    
    static func getLastCoo() -> CLLocationCoordinate2D? {
        let defaults = UserDefaults.standard
        if let latitude = defaults.value(forKey: Spot.keyCooX) as? Double, let longitude = defaults.value(forKey: Spot.keyCooY) as? Double {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return nil
    }
    
    func reset() {
        
        self.descriptions = Variable([])
        self.title.value = String()
        self.adress = String()
        self.coordinate.value = nil
        self.picture = nil
        
        GeolocationService.instance.startUpdatingLocation()
        GeolocationService.instance.location
            .asObservable()
            .debounce(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                descriptions in
                print("reset : \(descriptions)")
                self.coordinate.value = descriptions
                GeolocationService.instance.stopUpdatingLocation()
            }).addDisposableTo(disposeBag)
    }
    
    let exactGeo = CLGeocoder()
    private func searchClosestState(newCoordinate:CLLocationCoordinate2D) {
        
        place = nil
        adress = String()
        
        let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
        
        exactGeo.reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) -> Void in
            
            if let placemarks = placemarks, let placemark = placemarks.first, let locality = placemark.locality {
                
                self.adress = placemark.stringAddress
                
                if let subLocality = placemark.subLocality {
                    self.place = "\(locality) \(subLocality)"
                } else {
                    self.place = locality
                }
            }
        })
    }
    
    /*
     //var closestPlaces = [String]() //
     //var farestPlaces = [String]() //
     
     var closestGeo = CLGeocoder()
     
     let kmToDegree = 0.008
     
     let nTest = 16
     let angle = 360.0/Double(nTest)
     
     //closestPlaces = [String]()
     //farestPlaces = [String]()
     let locations = Array(0...nTest).map({
     (val:Int) -> CLLocation in
     let alpha = angle/2 + Double(val)*angle
     let rayon = 2.0*kmToDegree
     let x1 = newCoordinate.latitude + rayon*cos(alpha)
     let y1 = newCoordinate.longitude + rayon*sin(alpha)
     
     return CLLocation(latitude: x1, longitude: y1)
     })
     
     nextSyncSearch(locations: locations, i: 0)*/
    
    /*private func nextSyncSearch(locations:[CLLocation], i:Int) {
     
        if i == locations.count {print(self.closestPlaces) ; return}
        
        closestGeo.reverseGeocodeLocation(locations[i], completionHandler: {
            (placemarks, error) -> Void in
            
            if let placemarks = placemarks, let placemark = placemarks.first, let locality = placemark.locality {
                
                if let subLocality = placemark.subLocality {
                    self.closestPlaces.append("\(locality) \(subLocality)")
                } else {
                    self.closestPlaces.append(locality)
                }
                self.nextSyncSearch(locations:locations, i:i+1)
            }
        })
    }*/
}

extension CLPlacemark {
    var postalAddress : CNPostalAddress? {
        get {
            guard let addressdictionary = self.addressDictionary else {
                return nil
            }
            let address = CNMutablePostalAddress()
            address.street = addressdictionary["Street"] as? String ?? ""
            address.state = addressdictionary["State"] as? String ?? ""
            address.city = addressdictionary["City"] as? String ?? ""
            address.country = addressdictionary["Country"] as? String ?? ""
            address.postalCode = addressdictionary["ZIP"] as? String ?? ""
            return address
        }
    }
    
    var stringAddress : String {
        get {
            var address = String()
            guard let addressdictionary = self.addressDictionary else {
                return address
            }
            address = address + (addressdictionary["Street"] as? String ?? "") + " "
            address = address + (addressdictionary["ZIP"] as? String ?? "") + " "
            address = address + (addressdictionary["City"] as? String ?? "") + " "
            address = address + (addressdictionary["State"] as? String ?? "") + " "
            address = address + (addressdictionary["Country"] as? String ?? "") + " "
            
            return address
        }
    }
}








