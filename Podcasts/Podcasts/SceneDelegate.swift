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
        
    lazy private var favouriteManager: FavouriteManagerInput = FavouriteManager(dataStoreManager: dataStoreManager, firebaseDatabase: firebaseDatabase)
    
    lazy private var listeningManager: ListeningManagerInput = {
        let manager = ListeningManager(dataStoreManager: dataStoreManager, firebaseDatabaseInput: firebaseDatabase)
        player.delegate = manager
        return manager
    }()
    
    lazy private var likeManager: LikeManagerInput =  LikeManager(dataStoreManager: dataStoreManager, firebaseDatabase: firebaseDatabase)
    
    lazy private var downloadService: DownloadServiceInput = {
        let service = DownloadService(dataStoreManager: dataStoreManager, networkMonitor: netWorkMonitor)
        favouriteManager.delegate = service
        return service
    }()
    
    lazy private var apiService: ApiServiceInput = ApiService(viewContext: dataStoreManager.viewContext)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        self.window?.rootViewController = preLoaderViewController()
        self.window?.makeKeyAndVisible()
        
        window?.overrideUserInterfaceStyle = userViewModel.userInterfaceStyleIsDark ? .dark : .light
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
                favouriteManager: favouriteManager,
                firestorageDatabase: firestorageDatabase,
                player: player,
                downloadService: downloadService,
                firebaseDataBase: firebaseDatabase,
                apiService: apiService,
                dataStoreManager: dataStoreManager,
                listeningManager: listeningManager)
        }
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
