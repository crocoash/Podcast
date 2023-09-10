//
//  DownloadService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 01.11.2021.
//

import UIKit
import CoreData

//MARK: - Type
protocol InputDownloadProtocol {
    var downloadEntity: DownloadProtocol { get }
}

//MARK: - Type
protocol DownloadProtocol {
    var downloadUrl: String? { get }
    var downloadId: String { get }
}

//MARK: - OutputType
struct DownloadServiceType: PodcastCellDownloadProtocol {
    
    var downloadId: String
    var inputDownloadProtocol: InputDownloadProtocol
    var downloadDataTask: URLSessionDownloadTask
    var isDownloaded: Bool = false
    var isDownloading: Bool = false
    var isGoingDownload: Bool = false
    var downloadingProgress: Float = 0
    var downloadTotalSize : String = ""
    
    var downloadUrl: URL?
    
    init(inputDownloadProtocol: InputDownloadProtocol, downloadDataTask: URLSessionDownloadTask) {
        self.downloadId = inputDownloadProtocol.downloadEntity.downloadId
        self.inputDownloadProtocol = inputDownloadProtocol
        self.downloadDataTask = downloadDataTask
        self.downloadUrl = inputDownloadProtocol.downloadEntity.downloadUrl.url
    }
}

//MARK: - Delegate
protocol DownloadServiceDelegate: AnyObject {
        
    func updateDownloadInformation (_ downloadService: DownloadService, entity: DownloadServiceType)
    func didEndDownloading         (_ downloadService: DownloadService, entity: DownloadServiceType)
    func didPauseDownload          (_ downloadService: DownloadService, entity: DownloadServiceType)
    func didContinueDownload       (_ downloadService: DownloadService, entity: DownloadServiceType)
    func didStartDownload          (_ downloadService: DownloadService, entity: DownloadServiceType)
    func didRemoveEntity           (_ downloadService: DownloadService, entity: DownloadServiceType)
}

//MARK: - Input
//protocol DownloadServiceInput: MultyDelegateServiceInput {
//    func isDownloaded(entity: InputDownloadProtocol) -> Bool
//    func conform(entity: InputDownloadProtocol)
//    func cancelDownload(_ entity: InputDownloadProtocol)
//}

class DownloadService: MultyDelegateService<DownloadServiceDelegate>, ISingleton {
    
    typealias DownloadsSession = [URL: DownloadServiceType]
    
    private let dataStoreManager: DataStoreManager
    private let networkMonitor: NetworkMonitor
    
    //MARK: init
    required init(container: IContainer, args: ()) {
        self.networkMonitor = container.resolve()
        self.dataStoreManager = container.resolve()
    }
  
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "BackGroundSession")
        let downloadsSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return downloadsSession
    }()
    
    private(set) var activeDownloads: DownloadsSession = [:]
    
    func isDownloaded(entity: InputDownloadProtocol) -> Bool {
        return entity.downloadEntity.downloadUrl.isDownloaded
    }
    
    func conform(entity: InputDownloadProtocol) {
        var entity = entity

        if let coredataProtocol = entity as? (any CoreDataProtocol) {
            
            if let savedEntity = dataStoreManager.fetchObject(entity: coredataProtocol, predicates: nil) as? InputDownloadProtocol {
                entity = savedEntity
            }
        }
        
        guard let url = entity.downloadEntity.downloadUrl.url else { fatalError() }
        
        if var activeDownload = activeDownloads[url] {
            let downloadState = activeDownload.downloadDataTask.state

            switch downloadState {
            case .running:
                suspendDownload(&activeDownload)
            case .suspended:
                continueDownload(&activeDownload)
            default: break
            }
            activeDownloads[url] = activeDownload
        } else {
            if isDownloaded(entity: entity) {
                cancelDownload(entity)
            } else {
                startDownload(InputDownloadProtocol: entity)
            }
        }
    }
    
    func cancelDownload(_ entity: InputDownloadProtocol) {
        guard let url = entity.downloadEntity.downloadUrl.localPath else { return }
        
        do {
            try FileManager.default.removeItem(atPath: url.path)
            
        } catch {
            print(error)
        }
        if let downloadServiceType = self.activeDownloads[url] {
            downloadServiceType.downloadDataTask.cancel()
            self.activeDownloads[url] = nil
            delegates {
                $0.didRemoveEntity(self, entity: downloadServiceType)
            }
        } else {
            let downloadServiceType = DownloadServiceType(inputDownloadProtocol: entity, downloadDataTask: downloadsSession.downloadTask(with: url))
            delegates {
                $0.didRemoveEntity(self, entity: downloadServiceType)
            }
        }
    }
}

//MARK: - Private Methods
extension DownloadService {

    private func startDownload(InputDownloadProtocol: InputDownloadProtocol) {
        
//        if !networkMonitor.isConnection {
//            Alert().create(for: vc, title: "No Internet") { _ in
//                [UIAlertAction(title: "Ok", style: .cancel) { _ in
//                    return
//                }]
//            }
//        } else if networkMonitor.connectionType == .cellular {
//            Alert().create(for: vc, title: "Use Mobile intertnet for downLoad? ") { _ in
//                [ UIAlertAction(title: "No", style: .cancel) { _ in
//                    return
//                }, UIAlertAction(title: "Yes", style: .default) { _ in
//                }]
//            }
//        }
        
        guard let url = InputDownloadProtocol.downloadEntity.downloadUrl.url else { fatalError() }

        let downloadDataTask = downloadsSession.downloadTask(with: url)
        downloadDataTask.resume()
        var downloadServiceType = DownloadServiceType(inputDownloadProtocol: InputDownloadProtocol, downloadDataTask: downloadDataTask)
        downloadServiceType.isGoingDownload = true
        activeDownloads[url] = downloadServiceType
        delegates {
            $0.didStartDownload(self, entity: downloadServiceType)
        }
    }
    
    private func continueDownload(_ downloadServiceType: inout DownloadServiceType) {
        downloadServiceType.downloadDataTask.resume()
        downloadServiceType.isGoingDownload = true
        delegates {
            $0.didContinueDownload(self, entity: downloadServiceType)
        }
    }
    
    private func suspendDownload(_ downloadServiceType: inout DownloadServiceType) {
        downloadServiceType.downloadDataTask.suspend()
        downloadServiceType.isDownloading = false
        
        delegates {
            $0.didPauseDownload(self, entity: downloadServiceType)
        }
        
    }
    
//    private func cancelDownload(_ entity: InputDownloadProtocol) {
        
//        Alert().create(for: vc, title: "Do you want remove podcast from your device?") {_ in
//            [UIAlertAction(title: "yes", style: .destructive) { [weak self] _ in
//                guard let self = self else { return }
//                self.cancelDownload(entity)
//            },
//             UIAlertAction(title: "Cancel", style: .cancel) {_ in
//                return
//            }]
//        }
//    }
}

//MARK: - URLSessionDownloadDelegate
extension DownloadService: URLSessionDelegate, URLSessionDownloadDelegate {
    
    ///downloadTask
    func urlSession(_ session                  : URLSession,
                    downloadTask               : URLSessionDownloadTask,
                    didWriteData bytesWritten  : Int64,
                    totalBytesWritten          : Int64,
                    totalBytesExpectedToWrite  : Int64) {
        
        guard let url = downloadTask.originalRequest?.url,
              var downloadServiceType = activeDownloads[url] else { return }
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        
        downloadServiceType.downloadingProgress = progress
        downloadServiceType.downloadTotalSize = totalSize
        downloadServiceType.isDownloading = true
        downloadServiceType.isGoingDownload = false
        activeDownloads[url] = downloadServiceType
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            delegates {
             $0.updateDownloadInformation(self, entity: downloadServiceType)
            }
        }
    }
    
    ///didFinishDownloadingTo
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager.default
        
        guard let url = downloadTask.originalRequest?.url else { return }
        let localPath = url.localPath
        
        do {
            try fileManager.copyItem(at: location, to: localPath)
        } catch {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        do {
            try fileManager.removeItem(at: location)
        } catch {
            print("Could not remove item at disk: \(error.localizedDescription)")
        }
        
        guard var downloadServiceType = activeDownloads[url] else { return }
        activeDownloads[url] = nil
        
        downloadServiceType.isDownloading = false
        downloadServiceType.isDownloaded = true
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            delegates {
                $0.didEndDownloading(self, entity: downloadServiceType)
            }
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}

//MARK: - FavouriteManagerDelegate
extension DownloadService: FavouriteManagerDelegate {
    
    func favouriteManager(_ favouriteManager: FavouriteManagerInput, didRemove favourite: FavouritePodcast) {
       cancelDownload(favourite)
    }
    
    func favouriteManager(_ favouriteManager: FavouriteManagerInput, didAdd favourite: FavouritePodcast) {}
}
