//
//  LikedMomentsManager.swift
//  Podcasts
//
//  Created by mac on 08.11.2021.
//

import Foundation
import CoreData

class LikedMomentsManager {
    
    private init() {}
    private static var uniqueInstance: LikedMomentsManager?
    static var shared: LikedMomentsManager { uniqueInstance ?? LikedMomentsManager() }
    
    private var viewContext = DataStoreManager.shared.viewContext
    
    private(set) lazy var likedMomentFetchResultController: NSFetchedResultsController<LikedMoment> = {
        let fetchRequest: NSFetchRequest<LikedMoment> = LikedMoment.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(LikedMoment.moment), ascending: true)]
        fetchRequest.returnsObjectsAsFaults = false
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchResultController.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return fetchResultController
    }()
    
   
}

extension LikedMomentsManager {
    var likeMoments: [LikedMoment] { likedMomentFetchResultController.fetchedObjects ?? [] }
    var countOfLikeMoments: Int { likeMoments.count }
    
    func deleteMoment(at indexPath: IndexPath) {
        let moment = likedMomentFetchResultController.object(at: indexPath)
        viewContext.delete(moment)
        DataStoreManager.shared.mySave()
    }
    
    func getLikeMoment(at indexPath: IndexPath) -> LikedMoment {
        return likedMomentFetchResultController.object(at: indexPath)
    }
}
