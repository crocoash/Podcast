//
//  UserDefaults.swift
//  Podcasts
//
//  Created by Anton on 21.08.2022.
//

import Foundation

extension UserDefaults {
    enum Local {
        private enum Keys: String {
            case allowWifiConnection
            case allowCellularConnection
            case askEverytime
            case permissionNetworkName
            case alwaysAllow
        }
        
        static var userDefaults = UserDefaults.standard
        
        static var wifiPermission: Bool {
          get { return userDefaults.bool(forKey: Keys.allowWifiConnection.rawValue) }
          set { userDefaults.setValue(newValue, forKey: Keys.allowWifiConnection.rawValue) }
        }
   
        static var cellularPermission: Bool {
          get { return userDefaults.bool(forKey: Keys.allowCellularConnection.rawValue) }
          set { userDefaults.setValue(newValue, forKey: Keys.allowCellularConnection.rawValue) }
        }
        
        static var askEverytime: Bool {
          get { return userDefaults.bool(forKey: Keys.askEverytime.rawValue) }
          set { userDefaults.setValue(newValue, forKey: Keys.askEverytime.rawValue) }
        }
        
        static var alwaysAllow: Bool {
          get { return userDefaults.bool(forKey: Keys.alwaysAllow.rawValue) }
          set { userDefaults.setValue(newValue, forKey: Keys.alwaysAllow.rawValue) }
        }
        
        static var permissionNetworkName: String? {
          get { return userDefaults.string(forKey: Keys.permissionNetworkName.rawValue) }
          set { userDefaults.setValue(newValue, forKey: Keys.permissionNetworkName.rawValue) }
        }
    }
}
