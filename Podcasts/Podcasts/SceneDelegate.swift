//
//  SceneDelegate.swift
//  Podcasts
//
//  Created by mac on 25.10.2021.
//

import UIKit
import AVKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var videoViewController: Player? = nil
    var avPlayerSavedReference: AVPlayer? = nil
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
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
}
