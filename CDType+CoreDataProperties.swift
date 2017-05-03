//
//  CDType+CoreDataProperties.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 03/05/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import CoreData

public class CDType: NSManagedObject {
    
    static func initType() {
        
        _ = iterateEnum(TypeSpot.self).filter({
            (type:TypeSpot) -> Bool in
            
            let request = CDType.fetchType()
            request.predicate = NSPredicate(format: "title == %@", type.rawValue)
            if (try! CDContext.sharedInstance.fetch(request)).count > 0 {
                return false
            } else {
                return true
            }
        }).map({
            (type:TypeSpot) in
            
            let newType = CDType(context: CDContext.sharedInstance)
            newType.title = type.rawValue
        })
        try! CDContext.sharedInstance.save()
    }
}

extension CDType {

    @nonobjc public class func fetchType() -> NSFetchRequest<CDType> {
        return NSFetchRequest<CDType>(entityName: "CDType")
    }

    @NSManaged public var title: String?
    @NSManaged public var describe1: NSSet?
    @NSManaged public var describe2: NSSet?
    @NSManaged public var describe3: NSSet?

}

// MARK: Generated accessors for describe1
extension CDType {

    @objc(addDescribe1Object:)
    @NSManaged public func addToDescribe1(_ value: CDDescribe)

    @objc(removeDescribe1Object:)
    @NSManaged public func removeFromDescribe1(_ value: CDDescribe)

    @objc(addDescribe1:)
    @NSManaged public func addToDescribe1(_ values: NSSet)

    @objc(removeDescribe1:)
    @NSManaged public func removeFromDescribe1(_ values: NSSet)

}

// MARK: Generated accessors for describe2
extension CDType {

    @objc(addDescribe2Object:)
    @NSManaged public func addToDescribe2(_ value: CDDescribe)

    @objc(removeDescribe2Object:)
    @NSManaged public func removeFromDescribe2(_ value: CDDescribe)

    @objc(addDescribe2:)
    @NSManaged public func addToDescribe2(_ values: NSSet)

    @objc(removeDescribe2:)
    @NSManaged public func removeFromDescribe2(_ values: NSSet)

}

// MARK: Generated accessors for describe3
extension CDType {

    @objc(addDescribe3Object:)
    @NSManaged public func addToDescribe3(_ value: CDDescribe)

    @objc(removeDescribe3Object:)
    @NSManaged public func removeFromDescribe3(_ value: CDDescribe)

    @objc(addDescribe3:)
    @NSManaged public func addToDescribe3(_ values: NSSet)

    @objc(removeDescribe3:)
    @NSManaged public func removeFromDescribe3(_ values: NSSet)

}
