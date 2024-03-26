//
//  addToLikeManager.swift
//  Podcasts
//
//  Created by Anton on 22.07.2023.
//

import CoreData

//MARK: - Delegate
protocol LikeManagerDelegate {
    func likeManager(_ LikeManager: LikeManager, didAdd likedMoment: LikedMoment)
    func likeManager(_ LikeManager: LikeManager, didRemove likedMoment: LikedMoment)
}

//MARK: -
//protocol LikeManagerInput: MultyDelegateServiceInput {
//    func addToLikedMoments(entity: Any, moment: Double)
//    func removeAll()
//    func removeFromLikedMoments(entity: LikedMoment)
//}

class LikeManager: MultypleDelegateService<LikeManagerDelegate>, ISingleton {
    
    lazy private var viewContext = dataStoreManager.viewContext
    
    private let dataStoreManager: DataStoreManager
    private let firebaseDatabase: FirebaseDatabase
    
    //MARK: init 
    required init(container: IContainer, args: ()) {
        self.dataStoreManager = container.resolve()
        self.firebaseDatabase = container.resolve()
        
        super.init()
        
        firebaseDatabase.observe(vc: self, viewContext: viewContext, type:  LikedMoment.self)
        firebaseDatabase.update(vc: self, viewContext: dataStoreManager.viewContext, type: LikedMoment.self)
    }
    
    func addToLikedMoments(entity: Any, moment: Double) {
        if let podcast = entity as? Podcast {
            let moment = LikedMoment(podcast: podcast, moment: moment, viewContext: viewContext, dataStoreManagerInput: dataStoreManager)
            firebaseDatabase.add(entity: moment)
            delegates {
                $0.likeManager(self, didAdd: moment)
            }
        }
    }
    
    func removeFromLikedMoments(entity: LikedMoment) {
        removeFromLikedMoments(entity: entity, removeFromFireBase: true)
    }
    
    
    func removeAll() {
        dataStoreManager.allObjectsFromCoreData(type: LikedMoment.self).forEach {
            removeFromLikedMoments(entity: $0, removeFromFireBase: true)
        }
    }
}

//MARK: - Private Methods
extension LikeManager {
    
    private func removeFromLikedMoments(entity: LikedMoment, removeFromFireBase: Bool) {
                
        let abstractLiked = dataStoreManager.initAbstractObject(for: entity)
        dataStoreManager.removeFromCoreData(entity: entity)
        
        if removeFromFireBase {
            firebaseDatabase.remove(entity: abstractLiked)
        }
        
        delegates {
            $0.likeManager(self, didRemove: abstractLiked)
        }
    }
    
    private func removeAllOnlyFromCoreData() {
        dataStoreManager.allObjectsFromCoreData(type: LikedMoment.self).forEach {
            removeFromLikedMoments(entity: $0, removeFromFireBase: false)
        }
    }
    
    private func saveLikedMoments(entity: LikedMoment) {
        if dataStoreManager.fetchObject(entity: entity, predicates: nil) == nil {
            let moment = LikedMoment(entity, viewContext: viewContext, dataStoreManagerInput: dataStoreManager)
            delegates {
                $0.likeManager(self, didAdd: moment)
            }
        }
    }

}

//MARK: - FirebaseDatabaseDelegate
extension LikeManager: FirebaseDatabaseDelegate {
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didGetEmptyData type: any FirebaseProtocol.Type) {
        if type is LikedMoment.Type {
            removeAllOnlyFromCoreData()
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entity: (any FirebaseProtocol)) {
        if let likedMoment = entity as? LikedMoment {
            saveLikedMoments(entity: likedMoment)
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didRemove entity: (any FirebaseProtocol)) {
        if let likedMoment = entity as? LikedMoment {
            removeFromLikedMoments(entity: likedMoment, removeFromFireBase: false)
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entities: [any FirebaseProtocol]) {}
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didUpdate entity: (any FirebaseProtocol)) {}
}
