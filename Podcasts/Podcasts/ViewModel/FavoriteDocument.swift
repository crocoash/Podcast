//
//  FavoriteDocument.swift
//  Pods
//
//  Created by Anton on 17.04.2022.
//

import Foundation
import CoreData

class FavoriteDocument {
    
    static var shared = FavoriteDocument()
    private init(){}
    
    private let viewContext = DataStoreManager.shared.viewContext
    private var favorite: [Podcast] { favoritePodcastFetchResultController.fetchedObjects ?? [] }
    
    lazy var favoritePodcastFetchResultController: NSFetchedResultsController<Podcast> = {
        let fetchRequest: NSFetchRequest<Podcast> = Podcast.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Podcast.trackName), ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "isFavorite = true")
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


extension FavoriteDocument {
    
    //MARK: - Favorite
    
    var favoritePodcasts: [Podcast] { favoritePodcastFetchResultController.fetchedObjects ?? [] }
    
    var countOffavoritePodcasts: Int { favoritePodcasts.count }
    
    var favoritePodcastIsEmpty: Bool { favoritePodcasts.isEmpty }
    
    func getfavoritePodcast(for indexPath: IndexPath) -> Podcast {
        return favoritePodcastFetchResultController.object(at: indexPath)
    }
    
    func getIndexPath(for podcast: Podcast) -> IndexPath? {
        return favoritePodcastFetchResultController.indexPath(forObject: podcast)
    }
    
    func removaAllFavorites() {
        favoritePodcastFetchResultController.fetchedObjects?.forEach {
            viewContext.delete($0)
        }
        DataStoreManager.shared.mySave()
    }
    
    func addOrRemoveToFavorite(podcast: Podcast) {
        podcast.isFavorite = !podcast.isFavorite
        DataStoreManager.shared.mySave()
    }
    
    //MARK: - Common
    
    func isDownload(podcast: Podcast) -> Bool {
        guard let url = podcast.previewUrl.localPath else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func podcastIsFavorite(podcast: Podcast) -> Bool {
        if let podcasts = favoritePodcastFetchResultController.fetchedObjects {
            return podcasts.contains { $0.id == podcast.id }
        }
        return false
    }
}
