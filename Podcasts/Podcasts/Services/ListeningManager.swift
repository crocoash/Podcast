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

extension ListeningManagerDelegate where Self: IViewModelUpdating {
    
    func listeningManager(_ listeningManager: ListeningManager, didSave listeningPodcast : ListeningPodcast) {
        update(with: listeningPodcast)
    }
    
    func listeningManager(_ listeningManager: ListeningManager, didRemove listeningPodcast: ListeningPodcast) {
        update(with: listeningPodcast)
    }
    
    func listeningManager(_ listeningManager: ListeningManager, didUpdate listeningPodcast: ListeningPodcast) {
        update(with: listeningPodcast)
    }
}

class ListeningManager: MultyDelegateService<ListeningManagerDelegate>, ISingleton {
    
    required init(container: IContainer, args: ()) {
        
        self.dataStoreManager = container.resolve()
        self.firebaseDatabase = container.resolve()
        self.player = container.resolve()
        
        super.init()

        self.player.delegate = self
        firebaseDatabase.update(vc: self, viewContext: dataStoreManager.viewContext, type: ListeningPodcast.self)
        firebaseDatabase.observe(vc: self, viewContext: dataStoreManager.viewContext, type: ListeningPodcast.self)
    }
    
    private let dataStoreManager: DataStoreManager
    private let firebaseDatabase: FirebaseDatabase
    private let player: Player
   
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
                
//                delegates {
//                    $0.listeningManager(self, didUpdate: listeningPodcast)
//                }
                
            } else {
                
                let podcast = dataStoreManager.getFromCoreDataIfNoSavedNew(entity: podcast)
                let listenigPodcast = ListeningPodcast.init(podcast, viewContext: dataStoreManager.viewContext, dataStoreManagerInput: dataStoreManager)
                
                firebaseDatabase.add(entity: listenigPodcast)
                
//                delegates {
//                    $0.listeningManager(self, didSave: listenigPodcast)
//                }
            }
        }
    }
    
    func removeListeningPodcast(_ entity: ListeningPodcast) {
        removeListeningPodcast(entity, removeFromFireBase: true)
    }
    
    func removeAll() {
        dataStoreManager.allObjectsFromCoreData(type: ListeningPodcast.self).forEach {
            removeListeningPodcast($0, removeFromFireBase: true)
        }
    }
}

//MARK: - Private Methods
extension ListeningManager {
    
    private func saveListeningPodcast(_ entity: ListeningPodcast) {
        let listeningPodcast = dataStoreManager.getFromCoreDataIfNoSavedNew(entity: entity)
        dataStoreManager.save()
        delegates {
            $0.listeningManager(self, didSave: listeningPodcast)
        }
    }
    
    private func removeListeningPodcast(_ entity: ListeningPodcast, removeFromFireBase: Bool) {
        
        let abstractListeningPodcast = dataStoreManager.initAbstractObject(for: entity)
        dataStoreManager.removeFromCoreData(entity: entity)
        
        if removeFromFireBase {
            firebaseDatabase.remove(entity: abstractListeningPodcast)
        }
        
        delegates {
            $0.listeningManager(self, didRemove: abstractListeningPodcast)
        }
    }
    
    private func removeAllOnlyFromCoreData() {
        dataStoreManager.allObjectsFromCoreData(type: ListeningPodcast.self).forEach {
            removeListeningPodcast($0, removeFromFireBase: false)
        }
    }
}

//MARK: - FirebaseDatabaseDelegate
extension ListeningManager: FirebaseDatabaseDelegate {
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didGetEmptyData type: any FirebaseProtocol.Type) {
        if type is ListeningPodcast.Type {
            removeAllOnlyFromCoreData()
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entity: (any FirebaseProtocol)) {
        if let listeningPodcast = entity as? ListeningPodcast {
            saveListeningPodcast(listeningPodcast)
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didRemove entity: (any FirebaseProtocol)) {
        if let listeningPodcast = entity as? ListeningPodcast {
            removeListeningPodcast(listeningPodcast, removeFromFireBase: true)
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entities: [any FirebaseProtocol]) {
        if let listeningPodcast = entities as? [ListeningPodcast] {
            dataStoreManager.updateCoreData(entities: entities)
        }
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didUpdate entity: (any FirebaseProtocol)) {
        if let listeningPodcast = entity as? ListeningPodcast {
            if player.currentTrack?.track.inputType.id != listeningPodcast.podcast.trackId {
                dataStoreManager.updateCoreData(entity: listeningPodcast)
                dataStoreManager.save()
                delegates {
                    $0.listeningManager(self, didUpdate: listeningPodcast)
                }
            }
        }
    }
}

//MARK: - PlayerDelegate
extension ListeningManager: PlayerDelegate {
    
    func playerDidEndPlay(_ player: Player, with track: any OutputPlayerProtocol) {}
    
    func playerStartLoading(_ player: Player, with track: any OutputPlayerProtocol) {}
    
    func playerDidEndLoading(_ player: Player, with track: any OutputPlayerProtocol) {}
    
    func playerUpdatePlayingInformation(_ player: Player, with track: any OutputPlayerProtocol) {
        saveListeningProgress(by: track as! Track)
    }
    
    func playerStateDidChanged(_ player: Player, with track: any OutputPlayerProtocol) {}
}
