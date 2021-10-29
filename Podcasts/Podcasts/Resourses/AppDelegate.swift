//
//  AppDelegate.swift
//  Podcasts
//
//  Created by mac on 25.10.2021.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
<<<<<<< HEAD:Podcasts/Podcasts/Resourses/AppDelegate.swift

=======
    
>>>>>>> Features/Registration:Podcasts/Podcasts/AppDelegate.swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
<<<<<<< HEAD:Podcasts/Podcasts/Resourses/AppDelegate.swift

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
=======
>>>>>>> Features/Registration:Podcasts/Podcasts/AppDelegate.swift
}
