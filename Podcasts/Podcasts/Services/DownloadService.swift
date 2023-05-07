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

    func conform(vc: UIViewController, entity: DownloadServiceProtocol, completion: @escaping () -> Void) {
     
        switch entity.stateOfDownload {
            
        case .notDownloaded:
            startDownload(vc: vc, entity, completion: completion)
            
        case .isDownloading:
            pauseDownload(entity)
            Alert().create(for: vc, title: "Do you want cancel downloading ?") { [weak self] _ in
                [UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                    self?.cancelDownload(entity)
                    completion()
                }, UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
                    self?.continueDownload(entity)
                    completion()
                }]
            }
            
        case .isDownload:
            Alert().create(for: vc, title: "Do you want remove podcast from your device?") { [weak self] _ in
                [UIAlertAction(title: "yes", style: .destructive) { [weak self] _ in
                    self?.cancelDownload(entity)
                    completion()
                }, UIAlertAction(title: "Cancel", style: .cancel) { _ in
                }
                ]
            }
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
    
    func endDownload(_ downloadServiceProtocol: DownloadServiceProtocol) {
        guard let url = downloadServiceProtocol.downloadUrl else { return }
        activeDownloads[url] = nil
    }
    
    func isDownLoad(_ downloadServiceProtocol: DownloadServiceProtocol) -> Bool {
        guard let url = downloadServiceProtocol.downloadUrl?.localPath else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func isDownloading(_ downloadServiceProtocol: DownloadServiceProtocol) -> Bool {
        guard let url = downloadServiceProtocol.downloadUrl else { return false }
        return activeDownloads[url] != nil
    }
}

//MARK: - Private Methods
extension DownloadService {
    
    private func startDownload(vc: UIViewController,_ downloadServiceProtocol: DownloadServiceProtocol, completion: @escaping () -> Void) {
        
        if !NetworkMonitor.shared.isConnection {
            Alert().create(for: vc, title: "No Internet") { _ in
                [UIAlertAction(title: "Ok", style: .cancel) { _ in
                    completion()
                }]
            }
            return
        } else if NetworkMonitor.shared.connectionType == .cellular {
            Alert().create(for: vc, title: "Use Mobile intertnet for downLoad? ") { _ in
                [ UIAlertAction(title: "No", style: .cancel) { _ in
                    completion()
                    return
                }, UIAlertAction(title: "Yes", style: .default) { _ in
                    completion()
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
    
    private func continueDownload(_ downloadServiceProtocol: DownloadServiceProtocol) {
        guard let url = downloadServiceProtocol.downloadUrl else { return }
        activeDownloads[url]?.downloadDataTask.resume()
    }
    
    private func pauseDownload(_ downloadServiceProtocol: DownloadServiceProtocol) {
        guard let url = downloadServiceProtocol.downloadUrl else { return }
        activeDownloads[url]?.downloadDataTask.suspend()
    }
}
