//
//  FavoriteDocument.swift
//  Pods
//
//  Created by Anton on 17.04.2022.
//

import Foundation
import CoreData

class FavoriteDocument {
    private let viewContext = DataStoreManager.shared.viewContext
    private var favorite: [Podcast] { favoritePodcastFetchResultController.fetchedObjects ?? [] }
    
    lazy var favoritePodcastFetchResultController: NSFetchedResultsController<Podcast> = {
        let fetchRequest: NSFetchRequest<Podcast> = Podcast.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Podcast.trackName), ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "isFavorite = true")
        
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
        viewContext.mySave()
    }
    
    func removeFromFavorites(podcast: Podcast) {
        podcast.isFavorite = false
        viewContext.mySave()
        
        guard let stringUrl = podcast.previewUrl,
              let url = URL(string: stringUrl) else { return }
        
        do {
            try FileManager.default.removeItem(at: url.locaPath)
        } catch (let err) {
            print("FAILED DELETEING VIDEO DATA \(err.localizedDescription)")
        }
    }
    
    //MARK: - Common
    func removeAll() {
        DataStoreManager.shared.removeAll(fetchRequest: Podcast.fetchRequest())
    }
    
    func downloadPodcast(podcast: Podcast) {
        if let podcast = viewContext.object(with: podcast.objectID) as? Podcast {
            podcast.isDownLoad = true
            viewContext.mySave()
        }
    }
   
    func isDownload(podcast: Podcast) -> Bool {
        guard let favoritePodcasts = favoritePodcastFetchResultController.fetchedObjects else { return false }
        if let podcast = favoritePodcasts.firstPodcast(matching: podcast.id) {
            return podcast.isDownLoad
        }
        return false
    }
   
    func podcastIsFavorite(podcast: Podcast) -> Bool {
        if let podcasts = favoritePodcastFetchResultController.fetchedObjects {
            return podcasts.contains { $0.id == podcast.id }
        }
        return false
    }
}
