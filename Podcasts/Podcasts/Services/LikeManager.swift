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
protocol LikeManagerInput: MultyDelegateServiceInput {
    func addToLikedMoments(entity: Any, moment: Double)
//    func saveLikedMoments(entity: LikedMoment)
//    func removeFromLikedMoments(entity: LikedMoment)
}

class LikeManager: MultyDelegateService<LikeManagerDelegate>, LikeManagerInput {
    
    lazy private var viewContext = dataStoreManager.viewContext
    
    private let dataStoreManager: DataStoreManagerInput
    private let firebaseDatabase: FirebaseDatabaseInput
    
    init(dataStoreManager: DataStoreManagerInput, firebaseDatabase: FirebaseDatabaseInput) {
        self.dataStoreManager = dataStoreManager
        self.firebaseDatabase = firebaseDatabase
        
        super.init()
        
        firebaseDatabase.delegate = self
        
        firebaseDatabase.update(viewContext: dataStoreManager.viewContext) { (result: Result<[LikedMoment]>) in }
        firebaseDatabase.observe(viewContext: viewContext,
                                 add: { (result: Result<LikedMoment>) in },
                                 remove: { (result: Result<LikedMoment>) in })
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
    
    ///from FireBase
    private func saveLikedMoments(entity: LikedMoment) {
        if dataStoreManager.fetchObject(entity: entity, predicates: nil) == nil {
            let moment = LikedMoment(entity, viewContext: viewContext, dataStoreManagerInput: dataStoreManager)
            delegates {
               $0.likeManager(self, didAdd: moment)
            }
        }
    }
    
    ///from FireBase
    private func removeFromLikedMoments(entity: LikedMoment) {
        dataStoreManager.removeFromCoreData(entity: entity)
        delegates {
            $0.likeManager(self, didRemove: entity)
        }
    }
    
    ///from FireBase
    private func removeAll() {
        dataStoreManager.allObjectsFromCoreData(type: LikedMoment.self).forEach {
            removeFromLikedMoments(entity: $0)
        }
    }
}

//MARK: - FirebaseDatabaseDelegate
extension LikeManager: FirebaseDatabaseDelegate {
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didGetEmptyData type: any FirebaseProtocol.Type) {
        if type is LikedMoment.Type {
          removeAll()
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entity: (any FirebaseProtocol)) {
        if let likedMoment = entity as? LikedMoment {
             saveLikedMoments(entity: likedMoment)
         }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didRemove entity: (any FirebaseProtocol)) {
        if let likedMoment = entity as? LikedMoment {
           removeFromLikedMoments(entity: likedMoment)
       }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entities: [any FirebaseProtocol]) {
        
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didUpdate entity: (any FirebaseProtocol)) {
        
    }
}
