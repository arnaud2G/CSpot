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
import AWSMobileHubHelper

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
    
    var descriptions = [TypeSpot]() // 3 - VuC2
    var title:Variable<String> = Variable(String()) // 2 - MyMap
    var adress:String = String() // 2 - MyMap
    
    var coordinate:CLLocationCoordinate2D? = nil // 2 - MyMap
    
    var picture:Variable<UIImage?> = Variable(nil) // 1 - MyCamera
    var pictureId:String? // 1 - MyCamera
    var place:String = String() // 2 - MyMap
    
    let disposeBag = DisposeBag()
    
    init() {
        picture.asObservable().subscribe(onNext:{
            description in
            if description == nil {
                self.pictureId = nil
            } else {
                self.pictureId = "\(AWSIdentityManager.default().identityId!):\(String(Int(NSDate().timeIntervalSince1970))).png"
            }
        }).addDisposableTo(disposeBag)
    }
    
    func reset() {
        
        self.descriptions = [TypeSpot]()
        self.title.value = String()
        self.adress = String()
        self.coordinate = nil
        self.picture.value = nil
        self.pictureId = nil
        self.place = String()
    }
    
    /*let exactGeo = CLGeocoder()
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
    }*/
    
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








