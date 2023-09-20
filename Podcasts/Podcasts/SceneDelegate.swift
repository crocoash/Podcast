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
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        self.window?.rootViewController = preLoaderViewController()
        self.window?.makeKeyAndVisible()
        
        //        window?.overrideUserInterfaceStyle = userViewModel.userInterfaceStyleIsDark ? .dark : .light
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
        let container = Container()
        let vc: PreLoaderViewController = container.resolve()
        return vc
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


