//
//  AddFavoriteManeger.swift
//  Podcasts
//
//  Created by Anton on 22.07.2023.
//

import UIKit
import CoreData
 
protocol FavoriteManagerDelegate: AnyObject {
    func favoriteManager(_ favoriteManager: FavoriteManager, didRemoveFavorite entity: any InputFavoriteType)
}

protocol InputFavoriteType: CoreDataProtocol {
    var favoriteInputTypeIdentifier: String { get }
}

class FavoriteManager {
    
    private let dataStoreManagerInput: DataStoreManagerInput
    lazy private var viewContext = dataStoreManagerInput.viewContext
    
    init(dataStoreManagerInput: DataStoreManagerInput) {
        self.dataStoreManagerInput = dataStoreManagerInput
    }
    
    weak var delegate: FavoriteManagerDelegate?
    
    var isEmpty: Bool {
        dataStoreManagerInput.allObjectsFromCoreData(type: FavoritePodcast.self).count == 0
    }
    
    func addOrRemoveFavoritePodcast(entity: (any InputFavoriteType)) {
        
        if let favoritePodcast = getFavorite(for: entity) {
            delegate?.favoriteManager(self, didRemoveFavorite: favoritePodcast)
            dataStoreManagerInput.removeFromCoreData(entity: favoritePodcast)
        } else {
            if let podcast = entity as? Podcast {
                FavoritePodcast(podcast, viewContext: viewContext, dataStoreManagerInput: dataStoreManagerInput)
            } else {
                dataStoreManagerInput.removeFromCoreData(entity: entity)
            }
        }
        
        feedbackGenerator()
    }
    
    func isFavorite(_ entity: any InputFavoriteType) -> Bool {
        return getFavorite(for: entity) != nil
    }
    
    func getFavorite(for entity: any InputFavoriteType) -> FavoritePodcast? {
        let predicate = NSPredicate(format: "podcast.identifier == %@", "\(entity.favoriteInputTypeIdentifier)")
        let favoritePodcast = dataStoreManagerInput.fetchObject(entity: FavoritePodcast.self, predicates: [predicate])
        return favoritePodcast
    }
    
    func removeAll() {
        dataStoreManagerInput.removeAll(type: FavoritePodcast.self)
    }
    
    private func feedbackGenerator() {
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
}
