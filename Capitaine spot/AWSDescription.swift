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

class AWSDescriptions: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _creationDate: NSNumber?
    var _spotId: String?
    var _type1: [String]?
    var _type2: [String]?
    var _type3: [String]?
    
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
            "_spotId" : "spotId",
            "_type1" : "type1",
            "_type2" : "type2",
            "_type3" : "type3",
        ]
    }
}

