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
    private let firestorageDatabase: FirestorageDatabaseInput = FirestorageDatabase()
    
    lazy private var netWorkMonitor: NetworkMonitor = {
        $0.delegate = self
        return $0
    }(NetworkMonitor())
    
    private let firebaseDatabase: FirebaseDatabaseInput = FirebaseDatabase()
    private let dataStoreManager: DataStoreManagerInput = (DataStoreManager())

    lazy private var player: InputPlayer = Player()
        
    lazy private var favoriteManager: FavoriteManagerInput = FavoriteManager(dataStoreManager: dataStoreManager, firebaseDatabase: firebaseDatabase)
    
    lazy private var listeningManager: ListeningManagerInput = {
        let manager = ListeningManager(dataStoreManager: dataStoreManager, firebaseDatabaseInput: firebaseDatabase)
        player.delegate = manager
        return manager
    }()
    
    lazy private var likeManager: LikeManagerInput =  LikeManager(dataStoreManager: dataStoreManager, firebaseDatabase: firebaseDatabase)
    
    lazy private var downloadService: DownloadServiceInput = {
        let service = DownloadService(dataStoreManager: dataStoreManager, networkMonitor: netWorkMonitor)
        favoriteManager.delegate = service
        return service
    }()
    
    lazy private var apiService: ApiServiceInput = ApiService(viewContext: dataStoreManager.viewContext)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        self.window?.rootViewController = preLoaderViewController()
        self.window?.makeKeyAndVisible()
        
        window?.overrideUserInterfaceStyle = userViewModel.userInterfaceStyleIsDark ? .dark : .light
        
        addFirebaseObserve()
        updateFromFirebase()
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
                favoriteManager: favoriteManager,
                firestorageDatabase: firestorageDatabase,
                player: player,
                downloadService: downloadService,
                firebaseDataBase: firebaseDatabase,
                apiService: apiService,
                dataStoreManager: dataStoreManager,
                listeningManager: listeningManager)
        }
    }
    
    private func updateFromFirebase() {
        
        firebaseDatabase.update(viewContext: dataStoreManager.viewContext) { (result: Result<[ListeningPodcast]>) in }
        
        firebaseDatabase.update(viewContext: dataStoreManager.viewContext) { (result: Result<[LikedMoment]>) in }
        
        firebaseDatabase.update(viewContext: dataStoreManager.viewContext) { (result: Result<[FavoritePodcast]>) in }
    }
    
    private func showError(_ error: MyError) {
        if let vc = window?.rootViewController {
            error.showAlert(vc: vc)
        }
    }
    
    private func addFirebaseObserve() {
        let viewContext = dataStoreManager.backgroundViewContext
        
        // FavoritePodcast
        firebaseDatabase.observe(
            viewContext: viewContext,
                
            add: { [weak self] (result: Result<FavoritePodcast>) in
                
            guard let self = self else { return }

                switch result {
                case .failure(error: let error):
                    showError(error)
                default: break
                }
            },
            
            remove: { [weak self] (result: Result<FavoritePodcast>) in
                guard let self = self else { return }
                
                switch result {
                case .failure(error: let error):
                    showError(error)
                default: break
                }
            })
        
        // LikedMoment
        firebaseDatabase.observe(viewContext: viewContext,
                                 add: { [weak self] (result: Result<LikedMoment>) in
            guard let self = self else { return }
            
            switch result {
           
            case .failure(error: let error):
                showError(error)
            default: break
            }
        }, remove: { [weak self] (result: Result<LikedMoment>) in
            guard let self = self else { return }
            
            switch result {
            case .failure(error: let error):
                showError(error)
            default: break
            }
        })
        
        // ListeningPodcast
        firebaseDatabase.observe( viewContext: viewContext,
                                  add: { [weak self] (result: Result<ListeningPodcast>) in
                guard let self = self else { return }

                switch result {
                case .failure(error: let error):
                    showError(error)
                default: break
                }
            }, remove: { [weak self] (result: Result<ListeningPodcast>) in
                guard let self = self else { return }

                switch result {
                case .failure(error: let error):
                    showError(error)
                default: break
                }
            })
    }
}



//MARK: - NetworkMonitorDelegate
extension SceneDelegate: NetworkMonitorDelegate {
    
    func internetConnectionDidRestore(_ networkMonitior: NetworkMonitor, isConnection: Bool) {
        let view = UIView(frame: self.window!.frame)
        view.backgroundColor = .blue
        window?.rootViewController?.view.addSubview(view)
    }
}
