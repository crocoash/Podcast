//
//  NetworkMonitior.swift
//  Podcasts
//
//  Created by Anton on 12.01.2023.
//

import UIKit
import Network

protocol NetworkMonitiorDelegate: AnyObject {
    func internetConnectionDidRestore(_ networkMonitior: NetworkMonitor)
}

class NetworkMonitor {
    
    static let shared: NetworkMonitor = NetworkMonitor()
    weak var delegate: NetworkMonitiorDelegate?
    
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    private(set) var isConnection: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if oldValue != self.isConnection {
                    self.delegate?.internetConnectionDidRestore(self)
//                    MyToast.create(title: "internet connection " + (self.isConnection ? "restored" : "lost"), .top)
                }
            }
        }
    }
    
    private init() {
        self.monitor = NWPathMonitor()
        monitor.start(queue: queue)
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
