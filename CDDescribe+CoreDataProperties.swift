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
    
    static func getDescribe(spotId:String) -> CDDescribe? {
        
        let request = CDDescribe.fetchDescribe()
        request.predicate = NSPredicate(format: "spotId == %@", spotId)
        let ret = try! CDContext.sharedInstance.fetch(request)
        if ret.count > 0 {
            return ret.first!
        } else {
            return nil
        }
    }
    
    static func addDescribe(descriptions:[TypeSpot], describe:AWSDescribes) {
        
        let cdTypes = descriptions.map({
            (type:TypeSpot) -> CDType in
            let typeRequest = CDType.fetchType()
            typeRequest.predicate = NSPredicate(format: "title == %@", type.rawValue)
            let cdTypes = try! CDContext.sharedInstance.fetch(typeRequest)
            return cdTypes.first!
        })
        
        let request = CDDescribe.fetchDescribe()
        request.predicate = NSPredicate(format: "spotId == %@", describe._spotId)
        let cdDescribes = try! CDContext.sharedInstance.fetch(request)
        if let cdDescribe = cdDescribes.first {
            cdDescribe.type1 = Set(cdTypes)
        } else {
            
            let newDescribe = CDDescribe(context: CDContext.sharedInstance)
            
            newDescribe.adress = describe._adress
            newDescribe.city = describe._city
            newDescribe.creationDate = Double(describe._creationDate)
            newDescribe.latitude = Double(describe._latitude)
            newDescribe.longitude = Double(describe._longitude)
            newDescribe.name = describe._name
            newDescribe.spotId = describe._spotId
            newDescribe.userId = describe._userId
            
            newDescribe.type1 = Set(cdTypes)
        }
        
        try! CDContext.sharedInstance.save()
    }
}

extension CDDescribe {

    @nonobjc public class func fetchDescribe() -> NSFetchRequest<CDDescribe> {
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
    @NSManaged public var type1: Set<CDType>!
    @NSManaged public var type2: Set<CDType>?
    @NSManaged public var type3: Set<CDType>?

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
