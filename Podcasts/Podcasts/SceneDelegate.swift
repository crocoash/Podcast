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
    private let netWorkMonitor = NetworkMonitor()
    
    lazy private var firebaseDatabase: FirebaseDatabase = {
        $0.delegate = self
        return $0
    }(FirebaseDatabase())
    
    private let player = Player()
    
    lazy private var dataStoreManagerInput: DataStoreManagerInput = {
        $0.delegate = self
        return $0
    }(DataStoreManager())
    
    lazy private var listeningManager = ListeningManager(dataStoreManagerInput: dataStoreManagerInput)
    lazy private var addToLikeManager = AddToLikeManager(dataStoreManagerInput: dataStoreManagerInput)
    lazy private var downloadService = DownloadService(dataStoreManagerInput: dataStoreManagerInput, networkMonitor: netWorkMonitor)
    lazy private var apiService = ApiService(viewContext: dataStoreManagerInput.viewContext)
    
    lazy private var favoriteManager: FavoriteManager = {
        let manager = FavoriteManager(dataStoreManagerInput: dataStoreManagerInput)
        manager.delegate = self
        return manager
    }()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        self.window?.rootViewController = preLoaderViewController()
        self.window?.makeKeyAndVisible()
        
        player.addObserverPlayerEventNotification(for: self)
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
                addToLikeManager: addToLikeManager,
                addToFavoriteManager: favoriteManager,
                firestorageDatabase: firestorageDatabase,
                player: player,
                downloadService: downloadService,
                firebaseDataBase: firebaseDatabase,
                apiService: apiService,
                dataStoreManagerInput: dataStoreManagerInput)
        }
    }
    
    private func updateFromFireBase() {
        let viewContext = dataStoreManagerInput.viewContext
        
        //FavoritePodcast
        firebaseDatabase.observe(
            
            viewContext: viewContext, add: { [weak self] (result: Result<FavoritePodcast>) in
                switch result {
                case .success(result: let favoritePodcast) :
                    self?.dataStoreManagerInput.saveInCoredataIfNotSaved(entity: favoritePodcast)
                case .failure(error: let error):
                    if let vc = self?.window?.rootViewController {
                        error.showAlert(vc: vc)
                    }
                }
            },
            
            remove: { [weak self] (result: Result<FavoritePodcast>) in
                switch result {
                case .success(result: let favoritePodcast):
                    self?.dataStoreManagerInput.removeFromCoreData(entity: favoritePodcast)
                case .failure(error: let error):
                    if let vc = self?.window?.rootViewController {
                        error.showAlert(vc: vc)
                    }
                }
            })
        
        ///LikedMoment
        firebaseDatabase.observe(
            viewContext: viewContext, add: { [weak self] (result: Result<LikedMoment>) in
                switch result {
                case .success(result: let likedMoment) :
                    self?.dataStoreManagerInput.saveInCoredataIfNotSaved(entity: likedMoment)
                case .failure(error: let error):
                    if let vc = self?.window?.rootViewController {
                        error.showAlert(vc: vc)
                    }                }
            }, remove: { [weak self] (result: Result<LikedMoment>) in
                switch result {
                case .success(result: let likedMoment):
                    self?.dataStoreManagerInput.removeFromCoreData(entity: likedMoment)
                case .failure(error: let error):
                    if let vc = self?.window?.rootViewController {
                        error.showAlert(vc: vc)
                    }
                }
            })
        
        ///ListeningPodcast
        firebaseDatabase.observe(
            viewContext: viewContext, add: { [weak self] (result: Result<ListeningPodcast>) in
                switch result {
                case .success(result: let listeningPodcast) :
                    self?.dataStoreManagerInput.saveInCoredataIfNotSaved(entity: listeningPodcast)
                case .failure(error: let error):
                    if let vc = self?.window?.rootViewController {
                        error.showAlert(vc: vc)
                    }                }
            }, remove: { [weak self] (result: Result<ListeningPodcast>) in
                switch result {
                case .success(result: let listeningPodcast):
                    self?.dataStoreManagerInput.removeFromCoreData(entity: listeningPodcast)
                case .failure(error: let error):
                    if let vc = self?.window?.rootViewController {
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
        let progress = track.listeningProgress ?? 0
        guard let inputListeningManager = entity as? (any InputListeningManager) else { fatalError() }
        listeningManager.saveListeningProgress(for: inputListeningManager, progress: progress)
    }
    
    func playerStateDidChanged(with track: OutputPlayerProtocol) {}
}

//MARK: - FirebaseDatabaseDelegate
extension SceneDelegate: FirebaseDatabaseDelegate {
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didGetEmptyData type: any FirebaseProtocol.Type) {
        dataStoreManagerInput.removeAll(type: type)
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didRemove entity: (any  FirebaseProtocol)) {
        dataStoreManagerInput.removeFromCoreData(entity: entity)
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entity: (any FirebaseProtocol)) {
        dataStoreManagerInput.addFromFireBase(entity: entity)
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didGet entities: [(any FirebaseProtocol)]) {
        //TODO: -
    }
    
    func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didUpdate entity: (any FirebaseProtocol)) {
        dataStoreManagerInput.updateCoreData(entity: entity)
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
