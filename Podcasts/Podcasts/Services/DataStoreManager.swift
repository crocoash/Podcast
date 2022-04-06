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
    func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                try context.parent?.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    lazy var mainViewContext: NSManagedObjectContext = persistentContainer.viewContext
    
    lazy var searchViewContext: NSManagedObjectContext = {
        let viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.parent = mainViewContext
        return viewContext
    }()
    
    lazy var playListViewContext: NSManagedObjectContext = {
        let viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.parent = mainViewContext
        return viewContext
    }()
    
    lazy var likeMomentViewContext: NSManagedObjectContext = {
        let viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.parent = mainViewContext
        return viewContext
    }()
    
    func removeAll<T: NSManagedObject>(viewContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<T>) {
            if let data = try? viewContext.fetch(fetchRequest), !data.isEmpty {
            data.forEach {
                viewContext.delete($0)
                save(context: viewContext)
            }
        }
    }
}

