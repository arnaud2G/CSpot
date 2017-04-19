//
//  AWSSpot.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 19/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

class AWSSpots: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _spotId: String?
    var _adress: String?
    var _description: [String: String]?
    var _latitude: NSNumber?
    var _longitude: NSNumber?
    var _name: String?
    var _place: String?
    
    class func dynamoDBTableName() -> String {
        
        return "capitainespots-mobilehub-1128628836-Spots"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_spotId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_spotId" : "spotId",
            "_adress" : "adress",
            "_description" : "description",
            "_latitude" : "latitude",
            "_longitude" : "longitude",
            "_name" : "name",
            "_place" : "place",
        ]
    }
}

