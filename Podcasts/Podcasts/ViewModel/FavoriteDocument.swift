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
    private init() {}
    
    private let viewContext = DataStoreManager.shared.viewContext
    private var favoritePodcasts: [FavoritePodcast] { favoritePodcastFRC.fetchedObjects ?? [] }
    
    private(set) lazy var favoritePodcastFRC: NSFetchedResultsController<FavoritePodcast> = {
        let fetchRequest: NSFetchRequest<FavoritePodcast> = FavoritePodcast.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(FavoritePodcast.idd), ascending: true)]
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
    
    var podcasts: [Podcast] { favoritePodcastFRC.fetchedObjects?.compactMap { $0.podcast } ?? [] }
    
    var countOffavoritePodcasts: Int { favoritePodcasts.count }
    var favoritePodcastIsEmpty: Bool { favoritePodcasts.isEmpty }
    
    func getPodcast(for indexPath: IndexPath) -> Podcast {
        return favoritePodcastFRC.object(at: indexPath).podcast
    }
    
    func getIndexPath(for podcast: Podcast) -> IndexPath? {
        guard let favoritePodcast = favoritePodcasts.filter({ $0.podcast.id == podcast.id }).first else { return nil }
        return favoritePodcastFRC.indexPath(forObject: favoritePodcast)
    }
    
    func removaAllFavorites() {
        favoritePodcasts.forEach {
            viewContext.delete($0)
        }
        DataStoreManager.shared.viewContext.mySave()
    }
    
    func addOrRemoveToFavorite(podcast: Podcast) {
        if let favoritePodcast = getFavoritePodcast(podcast) {
            viewContext.delete(favoritePodcast)
        } else {
            _ = FavoritePodcast(podcast: podcast, date: String(describing: Date()) )
        }
        viewContext.mySave()
        FirebaseDatabase.shared.savePodcast()
    }
    
    //MARK: - Common
    func isDownload(podcast: Podcast) -> Bool {
        guard let url = podcast.previewUrl.localPath else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func isFavorite(_ podcast: Podcast) -> Bool {
        return favoritePodcasts.filter ({ $0.podcast.id == podcast.id }).first != nil
    }
    
    func getFavoritePodcast(_ podcast: Podcast) -> FavoritePodcast? {
        return favoritePodcasts.filter ({ $0.podcast.id == podcast.id }).first
    }
}






