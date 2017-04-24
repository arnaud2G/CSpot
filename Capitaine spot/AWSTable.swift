//
//  AWSTable.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 21/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

class AWSTableDescription {
    
    static func insertNewSpotWithCompletionHandler(_ completionHandler: @escaping (_ error: Error?) -> Void) {
        
        let objectMapper = AWSDynamoDBObjectMapper.default()
        
        let itemForGet: AWSDescriptions! = AWSDescriptions()
        
        itemForGet._userId = AWSIdentityManager.default().identityId!
        itemForGet._creationDate = NSNumber(value: Int(NSDate().timeIntervalSince1970*1000))
        
        itemForGet._type1 = Spot.newSpot.descriptions.filter{TypeSpot.spot.nextType.contains($0)}.map{$0.localizedString}
        
        var type2 = [String]()
        for type in TypeSpot.spot.nextType {
            type2.append(contentsOf: Spot.newSpot.descriptions.filter{type.nextType.contains($0)}.map{$0.localizedString})
        }
        if type2.count > 0 {
            itemForGet._type2 = type2
        }
        
        let type3 = ((Spot.newSpot.descriptions.map{$0.localizedString}).filter{!itemForGet._type1.contains($0)}).filter{!type2.contains($0)}
        if type3.count > 0 {
            itemForGet._type3 = type3
        }
        
        itemForGet._adress = Spot.newSpot.adress
        itemForGet._city = Spot.newSpot.place
        itemForGet._latitude = NSNumber(value:Spot.newSpot.coordinate!.latitude)
        itemForGet._longitude = NSNumber(value:Spot.newSpot.coordinate!.longitude)
        itemForGet._name = Spot.newSpot.title.value
        if let pictureId = Spot.newSpot.pictureId {
            itemForGet._pictureId = pictureId
        }
        
        objectMapper.save(itemForGet, completionHandler: {(error: Error?) -> Void in
            completionHandler(error)
        })
    }
}

class AWSTableSpot {
    
    static func getSpotWithCompletionHandler(name:String, place:String, _ completionHandler: @escaping (_ response: AWSDynamoDBObjectModel?, _ error: Error?) -> Void) {
        
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.load(AWSSpots.self, hashKey: name, rangeKey: place) {
            (response: AWSDynamoDBObjectModel?, error: Error?) in
            DispatchQueue.main.async(execute: {
                completionHandler(response, error)
            })
        }
    }
}
