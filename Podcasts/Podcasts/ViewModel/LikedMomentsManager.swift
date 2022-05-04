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
    
    private(set) lazy var likedMomentFRC: NSFetchedResultsController<LikedMoment> = {
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
    var podcast: [LikedMoment] { likedMomentFRC.fetchedObjects ?? [] }
    var countOfLikeMoments: Int { podcast.count }
    
    func deleteMoment(at indexPath: IndexPath) {
        let moment = likedMomentFRC.object(at: indexPath)
        viewContext.delete(moment)
        viewContext.mySave()
    }
    
    func getLikeMoment(at indexPath: IndexPath) -> LikedMoment {
        return likedMomentFRC.object(at: indexPath)
    }
    
    func getPodcast(for id: NSNumber) -> Podcast? {
        let podcasts = try? DataStoreManager.shared.viewContext.fetch(Podcast.fetchRequest())
        return podcasts?.first(matching: id)
    }
    
    func addLikeMoment(podcast: Podcast, moment: Double) {
        _ = LikedMoment(podcast: podcast, moment: moment)
        viewContext.mySave()
        FirebaseDatabase.shared.saveLikedMoment()
    }
}
