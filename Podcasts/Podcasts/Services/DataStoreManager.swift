//
//  CoreDataService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 19.03.2022.
//

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
    ///----------------------------------------------------------------------------------------------------------
    lazy var searchPodcastFetchResultController: NSFetchedResultsController<Podcast> = {
        let fetchRequest: NSFetchRequest<Podcast> = Podcast.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Podcast.trackName), ascending: true)]
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.fetchLimit = 1000
//        fetchRequest.fetchOffset = 4
        
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.mainViewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try! fetchResultController.performFetch()
        return fetchResultController
    }()
    
    lazy var searchAuthorFetchResultController: NSFetchedResultsController<Author> = {
        let fetchRequest: NSFetchRequest<Author> = Author.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Author.artistID), ascending: true)]
        
        fetchRequest.fetchLimit = 1000
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.mainViewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try! fetchResultController.performFetch()
        return fetchResultController
    }()
    
    lazy var favoritePodcastFetchResultController: NSFetchedResultsController<Podcast> = {
        let fetchRequest: NSFetchRequest<Podcast> = Podcast.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Podcast.trackName), ascending: true)]
        fetchRequest.fetchLimit = 1000
        fetchRequest.returnsObjectsAsFaults = false
        
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.mainViewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try! fetchResultController.performFetch()
        return fetchResultController
    }()
    ///----------------------------------------------------------------------------------------------------------
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    ///----------------------------------------------------------------------------------------------------------
    lazy var mainViewContext: NSManagedObjectContext = persistentContainer.viewContext
}

extension DataStoreManager {
    func removeAll<T: NSManagedObject>(viewContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<T>) {
            if let data = try? viewContext.fetch(fetchRequest), !data.isEmpty {
            data.forEach {
                viewContext.delete($0)
                viewContext.mySave()
            }
        }
    }
}

extension NSManagedObjectContext {
    func mySave() {
        if self.hasChanges {
            do {
                try self.save()
//                try self.parent?.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
