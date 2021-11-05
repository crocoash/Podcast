//
//  AppDelegate.swift
//  Podcasts
//
//  Created by mac on 25.10.2021.
//

import UIKit
import Firebase

// FIXME: Файлы AppDelegate и SceneDelegate - явно не относятся к ресурсам. Лучше создать для них отдельную папку и назвать ее Application, например

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var backgroundSessionCompletionHandler: (() -> Void)?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession handleEventsForBackgroundURLSessionidentifier: String,
                     completionHandler: @escaping () -> Void) {
      backgroundSessionCompletionHandler = completionHandler
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
