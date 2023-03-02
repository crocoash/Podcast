//
//  DownloadService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 01.11.2021.
//

import UIKit

enum Props {
    case podcast
}

protocol DownloadServiceProtocol {
    var downloadUrl: URL? { get }
    var id: NSNumber? { get }
    var stateOfDownload: StateOfDownload { get }
}

enum StateOfDownload {
   case isDownload
   case isDownloading
   case notDownloaded 
}


class DownloadService {
    
    static var shared: DownloadService = DownloadService()
    private init() {}
    
    var downloadsSession: URLSession!
    
    private(set) var activeDownloads: [URL: (downloadServiceProtocol: DownloadServiceProtocol, downloadDataTask: URLSessionDownloadTask)] = [:]
    
    func configureURLSession(delegate: URLSessionDelegate) {
        let configuration = URLSessionConfiguration.background(withIdentifier: "BackGroundSession")
        self.downloadsSession = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
    
    func startDownload(vc: UIViewController,_ downloadServiceProtocol: DownloadServiceProtocol) {
        
        if !NetworkMonitor.shared.isConnection {
            Alert().create(for: vc, title: "No Internet") { _ in
                [UIAlertAction(title: "Ok", style: .cancel)]
            }
            return
        } else if NetworkMonitor.shared.connectionType == .cellular {
            Alert().create(for: vc, title: "Used Mobile intertnet for downLoad? ") { _ in
                [ UIAlertAction(title: "Now", style: .cancel) { _ in
                    vc.dismiss(animated: true)
                    return
                }, UIAlertAction(title: "Yes", style: .default) { _ in
                    vc.dismiss(animated: true)
                }]
            }
        }
        
        if let url = downloadServiceProtocol.downloadUrl, activeDownloads[url] == nil {
            let downloadDataTask = downloadsSession.downloadTask(with: url)
            downloadDataTask.resume()
            let entity = (downloadServiceProtocol: downloadServiceProtocol, downloadDataTask: downloadDataTask)
            activeDownloads[url] = entity
        }
    }
    
    func cancelDownload(_ downloadServiceProtocol: DownloadServiceProtocol) {
        guard let url = downloadServiceProtocol.downloadUrl else { return }
        activeDownloads[url]?.downloadDataTask.cancel()
        activeDownloads[url] = nil
        
        do {
            try FileManager.default.removeItem(at: url.localPath)
        } catch {
            print(error)
        }
    }
    
    func continueDownload(_ downloadServiceProtocol: DownloadServiceProtocol) {
        guard let url = downloadServiceProtocol.downloadUrl else { return }
        activeDownloads[url]?.downloadDataTask.resume()
    }
    
    func pauseDownload(_ downloadServiceProtocol: DownloadServiceProtocol) {
        guard let url = downloadServiceProtocol.downloadUrl else { return }
        activeDownloads[url]?.downloadDataTask.suspend()
    }
    
    func endDownload(_ downloadServiceProtocol: DownloadServiceProtocol) {
        guard let url = downloadServiceProtocol.downloadUrl else { return }
        activeDownloads[url] = nil
    }
    
    func isDownloading(_ downloadServiceProtocol: DownloadServiceProtocol) -> Bool {
        guard let url = downloadServiceProtocol.downloadUrl else { return false }
        return activeDownloads[url] != nil
    }
    
    func isDownLoad(_ downloadServiceProtocol: DownloadServiceProtocol) -> Bool {
        guard let url = downloadServiceProtocol.downloadUrl?.localPath else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
}
