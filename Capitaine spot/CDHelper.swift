//
//  CDHelper.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 03/05/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//
import Foundation
import CoreData

class CDHelper {
    
    static let sharedInstance = CDHelper()
    let UserDefaultShareKey: String = "group.avpro.CSpot"
    let modelName = "CDCSpot"
    
    // Définition de l'URL de l'emplacement de sauvegarde
    lazy var storeDirectory: URL = {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.UserDefaultShareKey)!
        
    }()
    
    // Retourne l'url de la base locale
    lazy var localStoreURL: URL = {
        let url = self.storeDirectory.appendingPathComponent("\(self.modelName).sqlite")
        return url
    }()
    
    // Définition de l'url du model
    lazy var modelURL: URL = {
        
        // Test la présence du fichier momd
        let bundle = Bundle.main
        if let url = bundle.url(forResource: self.modelName, withExtension: "momd") {
            return url
        }
        
        print("CRITICAL - Managed Object Model fil not found")
        
        abort()
        
    }()
    
    // Retourne le model associé au fichier momd
    lazy var model: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOf: self.modelURL)!
    }()
    
    // Retourne le coordinateur (model -> local)
    lazy var coordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        let mOption = [NSMigratePersistentStoresAutomaticallyOption:true, NSInferMappingModelAutomaticallyOption:true]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.localStoreURL, options: mOption)
        } catch {
            print("Could not add the persistent store")
            abort()
        }
        
        return coordinator
    }()
}

class CDContext:NSManagedObjectContext {
    
    // Share instance permet l'utilisation des fonctions en local
    static  let sharedInstance = CDContext()
    
    var nCount = 0
    init() {
        super.init(concurrencyType:  .mainQueueConcurrencyType)
        self.persistentStoreCoordinator = CDHelper.sharedInstance.coordinator
        self.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
        self.shouldDeleteInaccessibleFaults = true
        nCount = nCount + 1
        if nCount > 1 { fatalError("Ne doit être appellé qu'une fois") }
        else {print("DisplayContext initialisé")}
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func deleteAllData(entity: String) throws {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        let results = try self.fetch(fetchRequest) as! [NSManagedObject]
        _ = results.map({
            (result:NSManagedObject) in
            self.delete(result)
        })
        try self.save()
    }
    
    func initType() {
    }
}

