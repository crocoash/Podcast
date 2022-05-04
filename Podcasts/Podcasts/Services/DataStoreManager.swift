//
//  CoreDataService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 19.03.2022.
//

import CoreData

class DataStoreManager {
    
    static var shared: DataStoreManager = DataStoreManager()
    private init() {}
    
    private(set) var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy private(set) var viewContext: NSManagedObjectContext = persistentContainer.viewContext
}

extension DataStoreManager {
    
    func removeAll<T: NSManagedObject>(fetchRequest: NSFetchRequest<T>) {
        if let data = try? viewContext.fetch(fetchRequest), !data.isEmpty {
            data.forEach {
                viewContext.delete($0)
            }
        }
        viewContext.mySave()
    }
}

extension NSManagedObjectContext {
    func mySave() {
        if self.hasChanges {
            do {
                try self.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
