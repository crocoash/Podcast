//
//  FavoriteDocument.swift
//  Pods
//
//  Created by Anton on 17.04.2022.
//

import Foundation
import CoreData

class FavoriteDocument {
    
    let viewContext = DataStoreManager.shared.viewContext
    
    private init() {}
    static let shared = FavoriteDocument()
    
    lazy var favoritePodcastFRC: NSFetchedResultsController<FavoritePodcast> = {
        let fetchRequest = FavoritePodcast.fetchRequest()
        
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
    
    lazy var addFromFireBase: (FavoritePodcast) -> Void = { [weak self] in
        self?.getOrCreate(favoritePodcast: $0)
    }
    
    let removeFromFireBase: (FavoritePodcast) -> Void = {
        if let favoritePodcast = FavoriteDocument.shared.getFavoritePodcast(favoritePodcast: $0) {
            FavoriteDocument.shared.removeFromDevice(favoritePodcast: favoritePodcast)
        }
    }
    
    func getIndexPath(id: NSNumber) -> IndexPath? {
        let fetchRequest = FavoritePodcast.fetchRequest()
        let predicate = NSPredicate(format: "podcast.id == %i", id)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        if let favoritePodcast = try? viewContext.fetch(fetchRequest).first {
            return getIndexPath(for: favoritePodcast)
        }
        return nil
    }
    
    func getIndexPath(by podcast: Podcast) -> IndexPath? {
        let fetchRequest = FavoritePodcast.fetchRequest()
        let predicate = NSPredicate(format: "podcast == %@", podcast)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        if let favoritePodcast = try? viewContext.fetch(fetchRequest).first {
            return getIndexPath(for: favoritePodcast)
        }
        return nil
    }

    //MARK: - Favorite
    
    var favoritePodcasts: [FavoritePodcast] { favoritePodcastFRC.fetchedObjects ?? [] }
    var podcasts: [Podcast] { favoritePodcastFRC.fetchedObjects?.compactMap { $0.podcast } ?? [] }
    var countOffavoritePodcasts: Int { favoritePodcastFRC.sections?.first?.numberOfObjects ?? 0 }
    var favoritePodcastIsEmpty: Bool { favoritePodcasts.isEmpty }
    
    func removaAllFavorites() {
        favoritePodcasts.forEach {
            remove(favoritePodcast: $0)
        }
    }
    
    func remove(favoritePodcast: FavoritePodcast) {
        let key = favoritePodcast.key
        removeFromDevice(favoritePodcast: favoritePodcast)
        removeFromFireBase(favoritePodcast: favoritePodcast, key)
    }
    
    func removeFromFireBase(favoritePodcast: FavoritePodcast ,_ key: String) {
        FirebaseDatabase.shared.remove(object: favoritePodcast, key: key)
    }
    
    func removeFromDevice(favoritePodcast: FavoritePodcast) {
        let podcast = favoritePodcast.podcast
        viewContext.delete(favoritePodcast)
        viewContext.mySave()
        Podcast.remove(podcast)
    }
    
    func addOrRemoveToFavorite(podcast: Podcast) {
        if let favoritePodcast = FavoriteDocument.shared.getFavoritePodcast(podcast) {
            remove(favoritePodcast: favoritePodcast)
        } else {
            let favoritePodcast = FavoritePodcast(podcast: podcast, date: String(describing: Date()))
            let key = favoritePodcast.key
            FirebaseDatabase.shared.add(object: favoritePodcast, key: key)
        }
    }
    
    func updateFavoritePodcastFromFireBase(completion: ((Result<[FavoritePodcast]>) -> Void)?) {
        FirebaseDatabase.shared.update { [weak self] (result: Result<[FavoritePodcast]>) in
            guard let self = self else { return }
            switch result {
            case .failure(let error) :
                
                if error == .noData {
                    self.favoritePodcasts.forEach {
                        self.removeFromDevice(favoritePodcast: $0)
                    }
                }
                
            case .success(let podcasts) :
                for favoritePodcast in self.favoritePodcasts {
                    if !podcasts.contains(where: { $0.podcast.id == favoritePodcast.podcast.id }) {
                        self.removeFromDevice(favoritePodcast: favoritePodcast)
                    }
                }
                
                podcasts.forEach { favoritePodcast in
                    self.getOrCreate(favoritePodcast: favoritePodcast)
                }
            }
            completion?(result)
        }
    }
    
    @discardableResult
    func getOrCreate(favoritePodcast: FavoritePodcast) -> FavoritePodcast {
        if let favoritePodcast = getFavoritePodcast(favoritePodcast: favoritePodcast) {
            return favoritePodcast
        }
        let podcast = favoritePodcast.podcast
        let idd = favoritePodcast.idd
        return FavoritePodcast(podcast: podcast, date: idd)
    }
    
    //MARK: - Common
    func isDownload(_ podcast: Podcast) -> Bool {
        guard let url = podcast.previewUrl.localPath else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func isFavorite(_ podcast: Podcast) -> Bool {
        return favoritePodcasts.filter { $0.podcast.id == podcast.id }.first != nil
    }
    
    func getFavoritePodcast(favoritePodcast: FavoritePodcast) -> FavoritePodcast? {
        return favoritePodcasts.filter { $0.podcast.id == favoritePodcast.podcast.id }.first
    }
    
    func getFavoritePodcast(_ podcast: Podcast) -> FavoritePodcast? {
        return favoritePodcasts.filter { $0.podcast.id == podcast.id }.first
    }
    
    func getIndexPath(for podcast: Podcast) -> IndexPath? {
        guard let favoritePodcast = favoritePodcasts.filter({ $0.podcast.id == podcast.id }).first else { return nil }
        return favoritePodcastFRC.indexPath(forObject: favoritePodcast)
    }
    
    func getIndexPath(for favoritePodcast: FavoritePodcast) -> IndexPath? {
        return favoritePodcastFRC.indexPath(forObject: favoritePodcast)
    }
    
    func getFavoritePodcast(by indexPath: IndexPath) -> FavoritePodcast {
        return favoritePodcastFRC.object(at: indexPath)
    }
    
    func getPodcast(by indexPath: IndexPath) -> Podcast {
        return favoritePodcastFRC.object(at: indexPath).podcast
    }
}
