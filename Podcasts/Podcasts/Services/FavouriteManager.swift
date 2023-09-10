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

//MARK: - Input
protocol FavouriteManagerInput: MultyDelegateServiceInput {
    func addFavouritePodcast(entity: Podcast)
    func removeFavouritePodcast(entity: FavouritePodcast)
    func removeFavouritePodcast(entity: Podcast)
    
    func isFavourite(_ entity: Podcast) -> Bool
    func removeAll()
}

class FavouriteManager: MultyDelegateService<FavouriteManagerDelegate>, FavouriteManagerInput, ISingleton {
    
    

    private let dataStoreManager: DataStoreManager
    private let firebaseDatabase: FirebaseDatabase
    lazy private var viewContext = dataStoreManager.viewContext
    
    required init(container: IContainer, args: ()) {
        
        self.firebaseDatabase = container.resolve()
        self.dataStoreManager = container.resolve()
        
        super.init()
        
        firebaseDatabase.update(vc: self, viewContext: dataStoreManager.viewContext, type: FavouritePodcast.self)
        firebaseDatabase.observe(vc: self, viewContext: viewContext, type: FavouritePodcast.self)
    }
    
    func removeFavouritePodcast(entity: FavouritePodcast) {
        removeFavouritePodcast(entity, removeFromFireBase: true)
    }
    
    func addFavouritePodcast(entity: Podcast) {
        if getFavourite(for: entity) == nil {
            let favouritePodcast = FavouritePodcast(entity, viewContext: viewContext, dataStoreManager: dataStoreManager)
            dataStoreManager.save()
            firebaseDatabase.add(entity: favouritePodcast)
            delegates {
                $0.favouriteManager(self, didAdd: favouritePodcast)
            }
        }
    }
    
    var isEmpty: Bool {
        dataStoreManager.allObjectsFromCoreData(type: FavouritePodcast.self).count == 0
    }
    
    func isFavourite(_ entity: Podcast) -> Bool {
        return getFavourite(for: entity) != nil
    }
    
    func removeAll() {
        dataStoreManager.allObjectsFromCoreData(type: FavouritePodcast.self).forEach {
            removeFavouritePodcast($0, removeFromFireBase: true)
        }
    }
    
    func removeFavouritePodcast(entity: Podcast) {
        
    }
}

//MARK: - Private Methods
extension FavouriteManager {
    
    private func removeAllOnlyFromCoredata() {
        dataStoreManager.allObjectsFromCoreData(type: FavouritePodcast.self).forEach {
            removeFavouritePodcast($0, removeFromFireBase: false)
        }
    }
    
    private func getFavourite(for entity: Podcast) -> FavouritePodcast? {
        let predicate = NSPredicate(format: "podcast.id == %@", "\(entity.id)")
        let favouritePodcast = dataStoreManager.fetchObject(entity: FavouritePodcast.self, predicates: [predicate])
        return favouritePodcast
    }
    
    private func removeFavouritePodcast(_ favouritePodcast: FavouritePodcast, removeFromFireBase: Bool = true) {
        
        guard favouritePodcast.managedObjectContext != nil else { return }
        
        let abstractFavourite = dataStoreManager.initAbstractObject(for: favouritePodcast)
        dataStoreManager.removeFromCoreData(entity: favouritePodcast)
        
        if removeFromFireBase {
            firebaseDatabase.remove(entity: abstractFavourite)
        }
        delegates {
            $0.favouriteManager(self, didRemove: abstractFavourite)
        }
    }
}

//MARK: - FirebaseDatabaseDelegate
extension FavouriteManager: FirebaseDatabaseDelegate {
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didGetEmptyData type: any FirebaseProtocol.Type) {
        if type is FavouritePodcast.Type {
            removeAllOnlyFromCoredata()
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
            removeFavouritePodcast(favouritePodcast, removeFromFireBase: false)
        }
    }
    
    ///update
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entities: [any FirebaseProtocol]) {
        if entities is [FavouritePodcast] {
            dataStoreManager.updateCoreData(entities: entities)
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didUpdate entity: (any FirebaseProtocol)) {}
}
