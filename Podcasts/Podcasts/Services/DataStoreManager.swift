//
//  CoreDataService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 19.03.2022.
//

import Foundation
//
//  DataStoreManager.swift
//  CoreDataLesson
//
//  Created by Tsvetkov Anton on 09.03.2022.
//

import Foundation
import CoreData

// MARK: - Core Data stack
class DataStoreManager {
    
    private init() {}
    
    static var dataStoreManager: DataStoreManager!
    static var shared: DataStoreManager {
        if dataStoreManager == nil {
            dataStoreManager = DataStoreManager()
        }
        return dataStoreManager
    }
    
    var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    lazy var viewContext: NSManagedObjectContext = persistentContainer.viewContext
    lazy var backgroundContext: NSManagedObjectContext = persistentContainer.newBackgroundContext()
}

