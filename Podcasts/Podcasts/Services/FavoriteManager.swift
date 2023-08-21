//
//  AddFavouriteManeger.swift
//  Podcasts
//
//  Created by Anton on 22.07.2023.
//

import UIKit
import CoreData
 
//MARK: - Delegate
protocol FavouriteManagerDelegate: AnyObject {
    func favouriteManager(_ favouriteManager: FavouriteManagerInput, didRemove favourite: FavouritePodcast)
    func favouriteManager(_ favouriteManager: FavouriteManagerInput, didAdd favourite: FavouritePodcast)
}

//MARK: - Type
protocol InputFavouriteType: CoreDataProtocol {
    var favouriteInputTypeid: String { get }
}

//MARK: - Input
protocol FavouriteManagerInput: MultyDelegateServiceInput {
    func addOrRemoveFavouritePodcast(entity: (any InputFavouriteType))
    func isFavourite(_ entity: any InputFavouriteType) -> Bool
    func removeAll()
}

class FavouriteManager: MultyDelegateService<FavouriteManagerDelegate>, FavouriteManagerInput {
    
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
        dataStoreManager.allObjectsFromCoreData(type: FavouritePodcast.self).count == 0
    }
    
    func addOrRemoveFavouritePodcast(entity: (any InputFavouriteType)) {
        if let favouritePodcast = getFavourite(for: entity) {
            removeFavouritePodcast(favouritePodcast)
        } else {
            addFavouritePodcast(entity: entity)
        }
    }
    
    private func removeFavouritePodcast(_ favouritePodcast: FavouritePodcast) {
        if let favouritePodcast = getFavourite(for: favouritePodcast.podcast) {
            let abstructFavourite = dataStoreManager.initAbstractObject(for: favouritePodcast)
            
            dataStoreManager.removeFromCoreData(entity: favouritePodcast)
            firebaseDatabase.remove(entity: abstructFavourite)
            
            delegates {
                $0.favouriteManager(self, didRemove: abstructFavourite)
            }
            feedbackGenerator()
        }
    }
    
    func isFavourite(_ entity: any InputFavouriteType) -> Bool {
        return getFavourite(for: entity) != nil
    }
    
    func removeAll() {
        dataStoreManager.allObjectsFromCoreData(type: FavouritePodcast.self).forEach {
            removeFavouritePodcast($0)
        }
    }
}

//MARK: - Private Methods
extension FavouriteManager {
    
    private func addFavouritePodcast(entity: (any InputFavouriteType)) {
        if getFavourite(for: entity) == nil {
            
            if let podcast = entity as? Podcast {
                let favouritePodcast = FavouritePodcast(podcast, viewContext: viewContext, dataStoreManager: dataStoreManager)
                dataStoreManager.save()
                firebaseDatabase.add(entity: favouritePodcast)
                delegates {
                    $0.favouriteManager(self, didAdd: favouritePodcast)
                }
            } else {
                //TODO: -
                fatalError()
                // dataStoreManagerInput.removeFromCoreData(entity: entity)
            }
            feedbackGenerator()
        }
    }
    
    private func getFavourite(for entity: any InputFavouriteType) -> FavouritePodcast? {
        let predicate = NSPredicate(format: "podcast.id == %@", "\(entity.favouriteInputTypeid)")
        let favouritePodcast = dataStoreManager.fetchObject(entity: FavouritePodcast.self, predicates: [predicate])
        return favouritePodcast
    }
    
    private func feedbackGenerator() {
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
}

//MARK: - FirebaseDatabaseDelegate
extension FavouriteManager: FirebaseDatabaseDelegate {
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didGetEmptyData type: any FirebaseProtocol.Type) {
        if type is FavouritePodcast.Type {
            removeAll()
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entity: (any FirebaseProtocol)) {
        if let favouritePodcast = entity as? FavouritePodcast {
            if dataStoreManager.fetchObject(entity: favouritePodcast, predicates: nil) == nil {
                let fav = FavouritePodcast(favouritePodcast, viewContext: viewContext, dataStoreManagerInput: dataStoreManager)
                delegates {
                    $0.favouriteManager(self, didAdd: fav)
                }
            }
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didRemove entity: (any FirebaseProtocol)) {
        if let favouritePodcast = entity as? FavouritePodcast {
            removeFavouritePodcast(favouritePodcast)
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entities: [any FirebaseProtocol]) {
        if entities is [FavouritePodcast] {
            dataStoreManager.updateCoreData(set: entities)
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didUpdate entity: (any FirebaseProtocol)) {
        if let favouritePodcast = entity as? FavouritePodcast? {
            
        }
    }
}
