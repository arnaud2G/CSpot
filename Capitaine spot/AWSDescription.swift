//
//  AWSDescription.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 19/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

class AWSDescriptions: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String!
    var _creationDate: NSNumber!
    var _type1: [String]!
    var _type2: [String]?
    var _type3: [String]?
    
    var _name:String!
    var _city:String!
    var _adress:String!
    var _latitude:NSNumber!
    var _longitude:NSNumber!
    var _pictureId:String?
    
    class func dynamoDBTableName() -> String {
        
        return "capitainespots-mobilehub-1128628836-Descriptions"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_creationDate"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_creationDate" : "creationDate",
            "_type1" : "type1",
            "_type2" : "type2",
            "_type3" : "type3",
            "_name" : "name",
            "_city" : "city",
            "_adress" : "adress",
            "_latitude" : "latitude",
            "_longitude" : "longitude",
            "_pictureId" : "pictureId",
        ]
    }
}

