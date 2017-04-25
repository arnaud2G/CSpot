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
    
    var _name: String!
    var _place: String!
    var _adress: String!
    var _latitude: NSNumber!
    var _longitude: NSNumber!
    var _pictureId: [String]?
    var _userId: [String]!
    var _dico: NSDictionary?
    var userDescription = [DescriptionSpot]()
    var userDistance:Int!
    
    class func dynamoDBTableName() -> String {
        
        return "capitainespots-mobilehub-1128628836-Spots"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_name"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_place"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_name" : "name",
            "_place" : "place",
            "_adress" : "adress",
            "_latitude" : "latitude",
            "_longitude" : "longitude",
            "_pictureId" : "pictureId",
            "_userId" : "userId",
        ]
    }
}

