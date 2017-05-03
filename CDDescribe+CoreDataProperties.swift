//
//  CDDescribe+CoreDataProperties.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 03/05/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import CoreData

public class CDDescribe: NSManagedObject {
    
}

extension CDDescribe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDDescribe> {
        return NSFetchRequest<CDDescribe>(entityName: "CDDescribe")
    }

    @NSManaged public var adress: String?
    @NSManaged public var city: String?
    @NSManaged public var creationDate: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var spotId: String?
    @NSManaged public var userId: String?
    @NSManaged public var type1: NSSet?
    @NSManaged public var type2: NSSet?
    @NSManaged public var type3: NSSet?

}

// MARK: Generated accessors for type1
extension CDDescribe {

    @objc(addType1Object:)
    @NSManaged public func addToType1(_ value: CDType)

    @objc(removeType1Object:)
    @NSManaged public func removeFromType1(_ value: CDType)

    @objc(addType1:)
    @NSManaged public func addToType1(_ values: NSSet)

    @objc(removeType1:)
    @NSManaged public func removeFromType1(_ values: NSSet)

}

// MARK: Generated accessors for type2
extension CDDescribe {

    @objc(addType2Object:)
    @NSManaged public func addToType2(_ value: CDType)

    @objc(removeType2Object:)
    @NSManaged public func removeFromType2(_ value: CDType)

    @objc(addType2:)
    @NSManaged public func addToType2(_ values: NSSet)

    @objc(removeType2:)
    @NSManaged public func removeFromType2(_ values: NSSet)

}

// MARK: Generated accessors for type3
extension CDDescribe {

    @objc(addType3Object:)
    @NSManaged public func addToType3(_ value: CDType)

    @objc(removeType3Object:)
    @NSManaged public func removeFromType3(_ value: CDType)

    @objc(addType3:)
    @NSManaged public func addToType3(_ values: NSSet)

    @objc(removeType3:)
    @NSManaged public func removeFromType3(_ values: NSSet)

}
