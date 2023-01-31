//
//  NetworkMonitior.swift
//  Podcasts
//
//  Created by Anton on 12.01.2023.
//

import UIKit
import Network

class NetworkMonitior {
    
    static let shared: NetworkMonitior = NetworkMonitior()
    
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    private(set) var isConnection: Bool = false{
        didSet {
            DispatchQueue.main.async {
                if oldValue != self.isConnection {
                    MyToast.create(title: "internet connection " + (self.isConnection ? "restored" : "lost"), .top)
                }
            }
        }
    }
    
    private init() {
        self.monitor = NWPathMonitor()
        monitor.start(queue: queue)
        NotificationCenter.default.addObserver(self, selector: #selector(noInternetConnectionAlert), name: Notification.Name.noInternet, object: nil)
    }
    
    @objc func noInternetConnectionAlert() {
        let vc = UIApplication.shared.windows.first?.rootViewController 
        MyError.noInternetConnection.showAlert(vc: vc)
    }
    
    private(set) var connectionType: ConnectionType = .unknown
    
    enum ConnectionType: String {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    func starMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isConnection = path.status == .satisfied
                self.getConnectionType(path)
            }
        }
    }
    
    func stopMonitor() {
        monitor.cancel()
    }
    
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
}
