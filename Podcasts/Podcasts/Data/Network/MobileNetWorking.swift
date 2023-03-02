//
//  MobileNetWorking.swift
//  Podcasts
//
//  Created by Anton on 21.08.2022.
//

import UIKit

class MobileNetwork {
    
    enum MobileStatus {
        case wiFi
        case alwaysAsk
        case alwaysAllow
    }
    
    static func configureNetworkPermission(network: MobileStatus) {
        UserDefaults.Local.wifiPermission = network == .wiFi
        UserDefaults.Local.cellularPermission = false
        UserDefaults.Local.askEverytime = network == .alwaysAsk
        UserDefaults.Local.alwaysAllow = network == .alwaysAllow
    }
    
    static func checkNetworkStatus(network: MobileStatus) -> Bool {
        let local = UserDefaults.Local.self
        
        switch network {
        case .wiFi:
            return local.wifiPermission && !local.cellularPermission && !local.askEverytime && !local.alwaysAllow
        case .alwaysAllow:
            return !local.wifiPermission && !local.cellularPermission && !local.askEverytime && local.alwaysAllow
        case .alwaysAsk:
            return !local.wifiPermission && !local.cellularPermission && local.askEverytime && !local.alwaysAllow
        }
    }
}
