//
//  SceneDelegate.swift
//  Podcasts
//
//  Created by mac on 25.10.2021.
//

import UIKit
import AVKit
import CoreData


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var videoViewController: Player? = nil
    private var avPlayerSavedReference: AVPlayer? = nil
    
    private let userViewModel = UserViewModel()
    private let firestorageDatabase = FirestorageDatabase()
    
    lazy private var netWorkMonitor: NetworkMonitor = {
        $0.delegate = self
        return $0
    }(NetworkMonitor())
    
    lazy private var firebaseDatabase: FirebaseDatabase = {
        $0.delegate = self
        return $0
    }(FirebaseDatabase())
    
    private let player: InputPlayer = Player()
    
    lazy private var dataStoreManager: DataStoreManagerInput = {
        $0.delegate = self
        return $0
    }(DataStoreManager())
    
    lazy private var listeningManager = ListeningManager(dataStoreManagerInput: dataStoreManager)
    lazy private var likeManager: InputLikeManager = {
        let likeManager = LikeManager(dataStoreManagerInput: dataStoreManager)
        likeManager.delegate = self
        return likeManager
    }()
    
    lazy private var downloadService: DownloadServiceInput = DownloadService(dataStoreManager: dataStoreManager, networkMonitor: netWorkMonitor)
    lazy private var apiService = ApiService(viewContext: dataStoreManager.viewContext)
    
    lazy private var favoriteManager: FavoriteManager = {
        let manager = FavoriteManager(dataStoreManagerInput: dataStoreManager)
        manager.delegate = self
        return manager
    }()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        self.window?.rootViewController = preLoaderViewController()
        self.window?.makeKeyAndVisible()
        
        updateFromFireBase()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        //      if let videoViewController = videoViewController {
        //        avPlayerSavedReference = videoViewController.playerAVP
        //      }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        //        if let videoViewController = videoViewController, let avPlayerSavedReference = avPlayerSavedReference {
        //            videoViewController.setPlayer(player: avPlayerSavedReference)
        //            self.avPlayerSavedReference = nil
        //        }
    }
    
    private func preLoaderViewController() -> UIViewController {
        
        return PreLoaderViewController.create { [weak self] coder in
            
            guard let self = self else { fatalError() }
            
            return PreLoaderViewController(
                coder: coder,
                userViewModel: userViewModel,
                likeManager: likeManager,
                addToFavoriteManager: favoriteManager,
                firestorageDatabase: firestorageDatabase,
                player: player,
                downloadService: downloadService,
                firebaseDataBase: firebaseDatabase,
                apiService: apiService,
                dataStoreManagerInput: dataStoreManager)
        }
    }
    
    private func updateFromFireBase() {
        let viewContext = dataStoreManager.backgroundViewContext
        
        // FavoritePodcast
        firebaseDatabase.observe(
            
            viewContext: viewContext, add: { [weak self] (result: Result<FavoritePodcast>) in
                guard let self = self else { return }

                switch result {
                case .success(result: let favoritePodcast) :
                    dataStoreManager.saveInCoredataIfNotSaved(entity: favoritePodcast)
                case .failure(error: let error):
                    if let vc = window?.rootViewController {
                        error.showAlert(vc: vc)
                    }
                }
            },
            
            remove: { [weak self] (result: Result<FavoritePodcast>) in
                guard let self = self else { return }
                
                switch result {
                case .success(result: let favoritePodcast):
                    dataStoreManager.removeFromCoreData(entity: favoritePodcast)
                case .failure(error: let error):
                    if let vc = window?.rootViewController {
                        error.showAlert(vc: vc)
                    }
                }
            })
        
        // LikedMoment
        firebaseDatabase.observe(
            viewContext: viewContext, add: { [weak self] (result: Result<LikedMoment>) in
                guard let self = self else { return }

                switch result {
                case .success(result: let likedMoment) :
                    dataStoreManager.saveInCoredataIfNotSaved(entity: likedMoment)
                case .failure(error: let error):
                    if let vc = window?.rootViewController {
                        error.showAlert(vc: vc)
                    }                }
            }, remove: { [weak self] (result: Result<LikedMoment>) in
                guard let self = self else { return }

                switch result {
                case .success(result: let likedMoment):
                    dataStoreManager.removeFromCoreData(entity: likedMoment)
                case .failure(error: let error):
                    if let vc = window?.rootViewController {
                        error.showAlert(vc: vc)
                    }
                }
            })
        
        // ListeningPodcast
        firebaseDatabase.observe(
            viewContext: viewContext, add: { [weak self] (result: Result<ListeningPodcast>) in
                guard let self = self else { return }

                switch result {
                case .success(result: let listeningPodcast) :
                    dataStoreManager.saveInCoredataIfNotSaved(entity: listeningPodcast)
                case .failure(error: let error):
                    if let vc = window?.rootViewController {
                        error.showAlert(vc: vc)
                    }                }
            }, remove: { [weak self] (result: Result<ListeningPodcast>) in
                guard let self = self else { return }

                switch result {
                case .success(result: let listeningPodcast):
                    dataStoreManager.removeFromCoreData(entity: listeningPodcast)
                case .failure(error: let error):
                    if let vc = window?.rootViewController {
                        error.showAlert(vc: vc)
                    }
                }
            })
    }
}

//MARK: - PlayerEventNotification
extension SceneDelegate: PlayerEventNotification {
    
    func playerDidEndPlay(with track: OutputPlayerProtocol) {}
    func playerStartLoading(with track: OutputPlayerProtocol) {}
    func playerDidEndLoading(with track: OutputPlayerProtocol) {}
    
    func playerUpdatePlayingInformation(with track: OutputPlayerProtocol) {
        let entity = track.inputType
        let progress = track.listeningProgress 
        guard let inputListeningManager = entity as? (any InputListeningManager) else { fatalError() }
        listeningManager.saveListeningProgress(for: inputListeningManager, progress: progress)
    }
    
    func playerStateDidChanged(with track: OutputPlayerProtocol) {}
}

//MARK: - FirebaseDatabaseDelegate
extension SceneDelegate: FirebaseDatabaseDelegate {
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didGetEmptyData type: any FirebaseProtocol.Type) {
        dataStoreManager.removeAll(type: type)
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didRemove entity: (any  FirebaseProtocol)) {
        dataStoreManager.removeFromCoreData(entity: entity)
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entity: (any FirebaseProtocol)) {
        dataStoreManager.getFromCoreDataIfNoSavedNew(entity: entity)
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didGet entities: [(any FirebaseProtocol)]) {
        //TODO: -
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didUpdate entity: (any FirebaseProtocol)) {
        dataStoreManager.updateCoreData(entity: entity)
    }
}

//MARK: - FavoriteManagerDelegate
extension SceneDelegate: FavoriteManagerDelegate {
    func favoriteManager(_ favoriteManager: FavoriteManager, didRemoveFavorite entity: (any InputFavoriteType)) {
        guard let donwloadType = entity as? (any InputDownloadProtocol) else { return }
        downloadService.cancelDownload(donwloadType)
    }
}

//MARK: - DataStoreManagerInputDelegate
extension SceneDelegate: DataStoreManagerDelegate {
    
    func dataStoreManager(_ dataStoreManagerInput: DataStoreManagerInput, didRemoveEntity entities: [NSManagedObject]) {
        entities.compactMap { $0 as? (any FirebaseProtocol)}.forEach  {
            firebaseDatabase.remove(entity: $0)
        }
    }
    
    func dataStoreManager(_ dataStoreManagerInput: DataStoreManagerInput, didUpdateEntity entities: [NSManagedObject]) {
        entities.compactMap { $0 as? (any FirebaseProtocol)}.forEach  {
            firebaseDatabase.add(entity: $0)
        }
    }
    
    func dataStoreManager(_ dataStoreManagerInput: DataStoreManagerInput, didAdd entities: [NSManagedObject]) {
        entities.compactMap { $0 as? (any FirebaseProtocol) }.forEach  {
            firebaseDatabase.add(entity: $0)
        }
    }
}

//MARK: - LikeManagerDelegate
extension SceneDelegate: LikeManagerDelegate {
    
    func likeManager(_ LikeManager: LikeManager, didAdd likedMoment: LikedMoment) {
        firebaseDatabase.add(entity: likedMoment)
    }
    
    func likeManager(_ LikeManager: LikeManager, didRemove likedMoment: LikedMoment) {
        firebaseDatabase.remove(entity: likedMoment)
    }
}

//MARK: - NetworkMonitorDelegate
extension SceneDelegate: NetworkMonitorDelegate {
    
    func internetConnectionDidRestore(_ networkMonitior: NetworkMonitor, isConnection: Bool) {
        print("print connection is \(isConnection)")
    }
}
