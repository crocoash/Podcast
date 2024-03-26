//
//  AppDelegate.swift
//  Podcasts
//
//  Created by mac on 25.10.2021.
//

import UIKit
import Firebase
import AVFoundation

@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    
   @MainActor var completion = {
       guard Thread.isMainThread else { fatalError() }
    }
    
    var backgroundSessionCompletionHandler: (() -> Void)?
    
    let orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        initialConfigurations()
        application.beginReceivingRemoteControlEvents()
        becomeFirstResponder()
        return true
    }
    
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession handleEventsForBackgroundURLSessionidentifier: String,
                     completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

extension AppDelegate {
    private func setupFirstMobileAllowWiFi() {
      if !UserDefaults.Local.wifiPermission && !UserDefaults.Local.cellularPermission && !UserDefaults.Local.askEverytime && !UserDefaults.Local.alwaysAllow {
        MobileNetwork.configureNetworkPermission(network: .alwaysAsk)
      }
    }
    
    private func initialConfigurations() {
        setupFirstMobileAllowWiFi()
        FirebaseApp.configure()
//         main()
    }
    
    func main() {
        Task { 
            await self.backgroundA()
            mainFunction()
            await self.backgroundB()
            
        }
    }

    func backgroundA() async {
//        try? await Task.sleep(nanoseconds: 3_000_000_000 )
//        print("backgroundA1")
        //        await MainActor.run {
//        mainFunction()
        //        }
        completion()
        print("backgroundA1")
    }
    
    func backgroundB() async {
        try? await Task.sleep(nanoseconds: 0)
        print("backgroundB")
    }
    
    @MainActor
    func mainFunction() {
        guard Thread.isMainThread else { fatalError() }
        print("mainFunction1")
        Thread.sleep(forTimeInterval: 5)
        print("mainFunction2")

    }
}
