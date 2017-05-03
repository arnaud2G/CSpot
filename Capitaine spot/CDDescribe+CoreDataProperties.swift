//
//  CDDescribe+CoreDataProperties.swift
//  
//
//  Created by 2Gather Arnaud Verrier on 03/05/2017.
//
//

import Foundation
import CoreData


extension CDDescribe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDDescribe> {
        return NSFetchRequest<CDDescribe>(entityName: "CDDescribe")
    }

    @NSManaged public var userId: String?
    @NSManaged public var spotId: String?
    @NSManaged public var creationDate: Double
    @NSManaged public var name: String?
    @NSManaged public var city: String?
    @NSManaged public var adress: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var type1: CDType?
    @NSManaged public var type2: CDType?
    @NSManaged public var type3: CDType?

}
