//
//  ListeningManager.swift
//  Podcasts
//
//  Created by Anton on 24.07.2023.
//

import Foundation

//MARK: - Delegate
protocol ListeningManagerDelegate: AnyObject {
    func listeningManager(_ listeningManager: ListeningManager, didSave listeningPodcast : ListeningPodcast)
    func listeningManager(_ listeningManager: ListeningManager, didRemove listeningPodcast: ListeningPodcast)
    func listeningManager(_ listeningManager: ListeningManager, didUpdate listeningPodcast: ListeningPodcast)
}

//MARK: - Type
//protocol ListeningManagerProtocol {
//    var trackId: String { get }
//    var listeningProgress: Double? { get }
//    var currentTime: Float? { get }
//    var duration: Double? { get }
//}

//MARK: - Input
protocol ListeningManagerInput: MultyDelegateServiceInput {
    func saveListeningProgress(by entity: Track)
    func removeListeningPodcast(_ entity: ListeningPodcast)
    func saveListeningPodcast(_ entity: ListeningPodcast)
}

class ListeningManager: MultyDelegateService<ListeningManagerDelegate>, ListeningManagerInput {
    
    private let dataStoreManager: DataStoreManagerInput
    private let firebaseDatabase: FirebaseDatabaseInput
    
    init(dataStoreManager: DataStoreManagerInput, firebaseDatabaseInput: FirebaseDatabaseInput) {
        self.dataStoreManager = dataStoreManager
        self.firebaseDatabase = firebaseDatabaseInput
        
        super.init()
        
        firebaseDatabaseInput.delegate = self
        
        firebaseDatabase.update(viewContext: dataStoreManager.viewContext) { (result: Result<[ListeningPodcast]>) in }
        
        firebaseDatabase.observe(viewContext: dataStoreManager.viewContext,
                                  add: { (result: Result<ListeningPodcast>) in },
                                  remove: { (result: Result<ListeningPodcast>) in })
    }
    
    func saveListeningProgress(by entity: Track) {
        
        if let podcast = entity.inputType as? Podcast {
            
            let predicate = NSPredicate(format: "podcast.id == %@", podcast.id)
            let listeningPodcast = dataStoreManager.fetchObject(entity: ListeningPodcast.self, predicates: [predicate])
            
            if let listeningPodcast = listeningPodcast {
                listeningPodcast.currentTime = entity.currentTime ?? 0
                listeningPodcast.progress = entity.listeningProgress ?? 0
                listeningPodcast.duration = entity.duration ?? 0
                dataStoreManager.save()
                
                firebaseDatabase.update(entity: listeningPodcast)
                
                delegates {
                    $0.listeningManager(self, didUpdate: listeningPodcast)
                }
                
            } else {
                
                let podcast = dataStoreManager.getFromCoreDataIfNoSavedNew(entity: podcast)
                let listenigPodcast = ListeningPodcast.init(podcast, viewContext: dataStoreManager.viewContext, dataStoreManagerInput: dataStoreManager)
                
                firebaseDatabase.add(entity: listenigPodcast)
                
                delegates {
                    $0.listeningManager(self, didSave: listenigPodcast)
                }
            }
        }
    }
    
    func saveListeningPodcast(_ entity: ListeningPodcast) {
        if dataStoreManager.fetchObject(entity: entity, predicates: nil) == nil {
            let listeningPodcast = ListeningPodcast(entity, viewContext: dataStoreManager.viewContext, dataStoreManagerInput: dataStoreManager)
            
            firebaseDatabase.add(entity: listeningPodcast)
            
            delegates {
                $0.listeningManager(self, didSave: listeningPodcast)
            }
        }
    }
    
    func removeListeningPodcast(_ entity: ListeningPodcast) {
        let abstructListeningPodcast = dataStoreManager.initAbstractObject(for: entity)
        dataStoreManager.removeFromCoreData(entity: entity)
        
        firebaseDatabase.remove(entity: abstructListeningPodcast)
        
        delegates {
            $0.listeningManager(self, didRemove: abstructListeningPodcast)
        }
    }
    
    func removeAll() {
        dataStoreManager.allObjectsFromCoreData(type: ListeningPodcast.self).forEach {
            removeListeningPodcast($0)
        }
    }
}

//MARK: - FirebaseDatabaseDelegate
extension ListeningManager: FirebaseDatabaseDelegate {
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didGetEmptyData type: any FirebaseProtocol.Type) {
        if type is ListeningPodcast.Type {
            removeAll()
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entity: (any FirebaseProtocol)) {
        if let listeningPodcast = entity as? ListeningPodcast {
            saveListeningPodcast(listeningPodcast)
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didRemove entity: (any FirebaseProtocol)) {
        if let listeningPodcast = entity as? ListeningPodcast {
            removeListeningPodcast(listeningPodcast)
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entities: [any FirebaseProtocol]) {
        if let likedMoments = entities as? [ListeningPodcast] {
            likedMoments.forEach {
                saveListeningPodcast($0)
            }
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didUpdate entity: (any FirebaseProtocol)) {
        if let listeningPodcast = entity as? ListeningPodcast {
            let entity = dataStoreManager.getFromCoreDataIfNoSavedNew(entity: listeningPodcast)
            entity.updateObject(by: listeningPodcast)
            dataStoreManager.save()
        }
    }
}

//MARK: - PlayerDelegate
extension ListeningManager: PlayerDelegate {
    
    func playerDidEndPlay(with track: OutputPlayerProtocol) {}
    
    func playerStartLoading(with track: OutputPlayerProtocol) {}
    
    func playerDidEndLoading(with track: OutputPlayerProtocol) {}
    
    func playerUpdatePlayingInformation(with track: OutputPlayerProtocol) {
        saveListeningProgress(by: track as! Track)
    }
    
    func playerStateDidChanged(with track: OutputPlayerProtocol) {}
}
