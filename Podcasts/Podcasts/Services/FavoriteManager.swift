//
//  AddFavoriteManeger.swift
//  Podcasts
//
//  Created by Anton on 22.07.2023.
//

import UIKit
import CoreData
 
//MARK: - Delegate
protocol FavoriteManagerDelegate: AnyObject {
    func favoriteManager(_ favoriteManager: FavoriteManagerInput, didRemove favorite: FavoritePodcast)
    func favoriteManager(_ favoriteManager: FavoriteManagerInput, didAdd favorite: FavoritePodcast)
}

//MARK: - Type
protocol InputFavoriteType: CoreDataProtocol {
    var favoriteInputTypeid: String { get }
}

//MARK: - Input
protocol FavoriteManagerInput: MultyDelegateServiceInput {
    func addOrRemoveFavoritePodcast(entity: (any InputFavoriteType))
    func isFavorite(_ entity: any InputFavoriteType) -> Bool
    func removeAll()
}

class FavoriteManager: MultyDelegateService<FavoriteManagerDelegate>, FavoriteManagerInput {
    
    private let dataStoreManager: DataStoreManagerInput
    private let firebaseDatabase: FirebaseDatabaseInput
    lazy private var viewContext = dataStoreManager.viewContext
    
    init(dataStoreManager: DataStoreManagerInput, firebaseDatabase: FirebaseDatabaseInput) {
        self.firebaseDatabase = firebaseDatabase
        self.dataStoreManager = dataStoreManager
        
        super.init()
        
        firebaseDatabase.delegate = self
    }
    
    var isEmpty: Bool {
        dataStoreManager.allObjectsFromCoreData(type: FavoritePodcast.self).count == 0
    }
    
    func addOrRemoveFavoritePodcast(entity: (any InputFavoriteType)) {
        if let favoritePodcast = getFavorite(for: entity) {
            removeFavoritePodcast(favoritePodcast)
        } else {
            addFavoritePodcast(entity: entity)
        }
    }
    
    private func removeFavoritePodcast(_ favoritePodcast: FavoritePodcast) {
        if let favoritePodcast = getFavorite(for: favoritePodcast.podcast) {
            let abstructFavorite = dataStoreManager.initAbstractObject(for: favoritePodcast)
            
            dataStoreManager.removeFromCoreData(entity: favoritePodcast)
            firebaseDatabase.remove(entity: abstructFavorite)
            
            delegates {
                $0.favoriteManager(self, didRemove: abstructFavorite)
            }
            feedbackGenerator()
        }
    }
    
    func isFavorite(_ entity: any InputFavoriteType) -> Bool {
        return getFavorite(for: entity) != nil
    }
    
    func removeAll() {
        dataStoreManager.allObjectsFromCoreData(type: FavoritePodcast.self).forEach {
            removeFavoritePodcast($0)
        }
    }
}

//MARK: - Private Methods
extension FavoriteManager {
    
    private func addFavoritePodcast(entity: (any InputFavoriteType)) {
        if getFavorite(for: entity) == nil {
            
            if let podcast = entity as? Podcast {
                let favoritePodcast = FavoritePodcast(podcast, viewContext: viewContext, dataStoreManager: dataStoreManager)
                dataStoreManager.save()
                firebaseDatabase.add(entity: favoritePodcast)
                delegates {
                    $0.favoriteManager(self, didAdd: favoritePodcast)
                }
            } else {
                //TODO: -
                fatalError()
                // dataStoreManagerInput.removeFromCoreData(entity: entity)
            }
            feedbackGenerator()
        }
    }
    
    private func getFavorite(for entity: any InputFavoriteType) -> FavoritePodcast? {
        let predicate = NSPredicate(format: "podcast.id == %@", "\(entity.favoriteInputTypeid)")
        let favoritePodcast = dataStoreManager.fetchObject(entity: FavoritePodcast.self, predicates: [predicate])
        return favoritePodcast
    }
    
    private func feedbackGenerator() {
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
}

//MARK: - FirebaseDatabaseDelegate
extension FavoriteManager: FirebaseDatabaseDelegate {
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didGetEmptyData type: any FirebaseProtocol.Type) {
        if type is FavoritePodcast.Type {
            removeAll()
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entity: (any FirebaseProtocol)) {
        if let favoritePodcast = entity as? FavoritePodcast {
            if dataStoreManager.fetchObject(entity: favoritePodcast, predicates: nil) == nil {
                let fav = FavoritePodcast(favoritePodcast, viewContext: viewContext, dataStoreManagerInput: dataStoreManager)
                delegates {
                    $0.favoriteManager(self, didAdd: fav)
                }
            }
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didRemove entity: (any FirebaseProtocol)) {
        if let favoritePodcast = entity as? FavoritePodcast {
            removeFavoritePodcast(favoritePodcast)
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entities: [any FirebaseProtocol]) {
        if entities is [FavoritePodcast] {
            dataStoreManager.updateCoreData(set: entities)
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didUpdate entity: (any FirebaseProtocol)) {
        if let favoritePodcast = entity as? FavoritePodcast? {
            
        }
    }
}
