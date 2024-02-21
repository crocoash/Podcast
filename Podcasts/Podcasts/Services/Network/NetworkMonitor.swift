//
//  NetworkMonitior.swift
//  Podcasts
//
//  Created by Anton on 12.01.2023.
//

import UIKit
import Network

//MARK: - Delegate
protocol NetworkMonitorDelegate: AnyObject {
    func internetConnectionDidRestore(_ networkMonitior: NetworkMonitor, isConnection: Bool)
}

class NetworkMonitor: ISingleton {
    
    weak var delegate: NetworkMonitorDelegate?
    
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    private(set) var isConnection: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if oldValue != isConnection {
                    delegate?.internetConnectionDidRestore(self, isConnection: isConnection)
                }
            }
        }
    }
    
    private(set) var connectionType: ConnectionType = .unknown
    
    enum ConnectionType: String {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    //MARK: init
    required init(container: IContainer, args: ()) {
        self.monitor = NWPathMonitor()
        monitor.start(queue: queue)
    }
    
    func starMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                isConnection = path.status == .satisfied
                getConnectionType(path)
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
