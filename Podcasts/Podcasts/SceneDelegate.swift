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
    var videoViewController: PlayerViewController? = nil
    var avPlayerSavedReference: AVPlayer? = nil
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
      if let videoViewController = videoViewController {
        avPlayerSavedReference = videoViewController.player
      }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        if let videoViewController = videoViewController, let avPlayerSavedReference = avPlayerSavedReference {
            videoViewController.player = avPlayerSavedReference
            self.avPlayerSavedReference = nil
        }
    }
}
