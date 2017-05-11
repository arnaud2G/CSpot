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

struct DescriptionSpot {
    var rVote:Int
    var typeSpot:TypeSpot
}

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
    
    static func testEnum(title:String) -> TypeSpot? {
        
        for type in iterateEnum(TypeSpot.self) {
            if type.rawValue == title {
                return type
            }
        }
        return nil
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
    
    var descriptions:Variable<[TypeSpot]> = Variable([]) // 3 - VuC2
    var title:Variable<String> = Variable(String()) // 2 - MyMap
    var spotId:Variable<String> = Variable(String()) // 2 - MyMap
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
        
        spotId.asObservable().subscribe(onNext:{
            spotId in
            if let describe = CDDescribe.getDescribe(spotId: spotId), let type = describe.type1, type.count > 0 {
                let titles = type.map{$0.title!}
                self.descriptions.value = iterateEnum(TypeSpot.self).filter{titles.contains($0.rawValue)}
            }
        }).addDisposableTo(disposeBag)
    }
    
    func reset() {
        
        self.descriptions = Variable([])
        self.title.value = String()
        self.adress = String()
        self.coordinate = nil
        self.picture.value = nil
        self.pictureId = nil
        self.place = String()
    }
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
    
    var stringAddress2 : String {
        get {
            var address = String()
            guard let addressdictionary = self.addressDictionary else {
                return address
            }
            address = address + (addressdictionary["Street"] as? String ?? "") + "\n"
            address = address + (addressdictionary["ZIP"] as? String ?? "") + " "
            address = address + (addressdictionary["City"] as? String ?? "") + " "
            address = address + (addressdictionary["State"] as? String ?? "") + " "
            address = address + (addressdictionary["Country"] as? String ?? "") + " "
            
            return address
        }
    }
}








