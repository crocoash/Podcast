//
//  DownloadService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 01.11.2021.
//

import UIKit
import CoreData

//enum Props {
//    case podcast
//}

protocol DownloadProtocol {
    var downloadUrl: String? { get }
    var identifier: String { get }
}

extension DownloadProtocol {
    
    var isDownloaded: Bool {
        downloadUrl.isDownloaded
    }
    
    func cust<T>(_ type: T.Type) -> T? {
        return self as? T
    }
}
//TODO: Download Event

struct DownloadServiceType {
    var downloadProtocol: DownloadProtocol
        
    var downloadDataTask: URLSessionDownloadTask?
    var isDownloading: Bool = false
    var isGoingDownload: Bool = false
    var downloadingProgress: Float = 0
    var downloadTotalSize : String = ""
    
    var downloadUrl: URL? {
        downloadProtocol.downloadUrl.url
    }
}

protocol DownloadServiceDelegate where Self: AnyObject {
    
    func updateDownloadInformation (_ downloadService: DownloadService, entity: DownloadServiceType)
    func didEndDownloading         (_ downloadService: DownloadService, entity: DownloadServiceType)
    func didPauseDownload          (_ downloadService: DownloadService, entity: DownloadServiceType)
    func didContinueDownload       (_ downloadService: DownloadService, entity: DownloadServiceType)
    func didStartDownload          (_ downloadService: DownloadService, entity: DownloadServiceType)
    func didRemoveEntity           (_ downloadService: DownloadService, entity: DownloadServiceType)
}

class DownloadService: NSObject {
    
    typealias DownloadsSession = [URL: DownloadServiceType]
    
    var delegate: DownloadServiceDelegate?
    
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "BackGroundSession")
        let downloadsSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return downloadsSession
    }()
    
    private(set) var activeDownloads: DownloadsSession = [:]
    
    func conform(vc: UIViewController, entity: DownloadProtocol) {
        var entity = entity

        if let coreDataProtocol = entity as? (any CoreDataProtocol) {
            if let entityFromCoreData = coreDataProtocol.getFromCoreData as? DownloadProtocol {
                entity = entityFromCoreData
            }
        }
        guard let url = entity.downloadUrl.url else { fatalError() }
        
        if var activeDownload = activeDownloads[url] {
            let downloadState = activeDownload.downloadDataTask?.state

            switch downloadState {
            case .running:
                suspendDownload(for: vc, &activeDownload)
            case .canceling:
                fatalError("interesting")
            case .completed:
                fatalError("interesting")
            case .suspended:
                continueDownload(for: vc, &activeDownload)
            default: break
            }
            activeDownloads[url] = activeDownload
        } else {
            if entity.isDownloaded {
                cancelDownload(for: vc, entity)
            } else {
                startDownload(vc: vc, entity)
            }
        }
    }
    
    func cancelDownload(_ entity: DownloadProtocol) {
        guard let url = entity.downloadUrl.localPath else { return }
        
        do {
            try FileManager.default.removeItem(atPath: url.path)
        } catch {
            print(error)
        }
        if let downloadServiceType = self.activeDownloads[url] {
            downloadServiceType.downloadDataTask?.cancel()
            self.activeDownloads[url] = nil
            self.delegate?.didRemoveEntity(self, entity: downloadServiceType)
        } else {
            let downloadServiceType = DownloadServiceType(downloadProtocol: entity)
            self.delegate?.didRemoveEntity(self, entity: downloadServiceType)
        }
    }
}

//MARK: - Private Methods
extension DownloadService {

    private func startDownload(vc: UIViewController,_ downloadProtocol: DownloadProtocol) {
        
        if !NetworkMonitor.shared.isConnection {
            Alert().create(for: vc, title: "No Internet") { _ in
                [UIAlertAction(title: "Ok", style: .cancel) { _ in
                    return
                }]
            }
        } else if NetworkMonitor.shared.connectionType == .cellular {
            Alert().create(for: vc, title: "Use Mobile intertnet for downLoad? ") { _ in
                [ UIAlertAction(title: "No", style: .cancel) { _ in
                    return
                }, UIAlertAction(title: "Yes", style: .default) { _ in
                }]
            }
        }
        
        guard let url = downloadProtocol.downloadUrl.url else { fatalError() }

        let downloadDataTask = downloadsSession.downloadTask(with: url)
        downloadDataTask.resume()
        var downloadServiceType = DownloadServiceType(downloadProtocol: downloadProtocol, downloadDataTask: downloadDataTask)
        downloadServiceType.isGoingDownload = true
        activeDownloads[url] = downloadServiceType
        delegate?.didStartDownload(self, entity: downloadServiceType)
    }
    
    private func continueDownload(for vc: UIViewController,_ downloadServiceType: inout DownloadServiceType) {
        downloadServiceType.downloadDataTask?.resume()
        downloadServiceType.isGoingDownload = true
        delegate?.didContinueDownload(self, entity: downloadServiceType)
    }
    
    private func suspendDownload(for vc: UIViewController, _ downloadServiceType: inout DownloadServiceType) {
        downloadServiceType.downloadDataTask?.suspend()
        downloadServiceType.isDownloading = false
        delegate?.didPauseDownload(self, entity: downloadServiceType)
    }
    
    private func cancelDownload(for vc: UIViewController,_ entity: DownloadProtocol) {
        
        Alert().create(for: vc, title: "Do you want remove podcast from your device?") {_ in
            [UIAlertAction(title: "yes", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.cancelDownload(entity)
            },
             UIAlertAction(title: "Cancel", style: .cancel) {_ in
                return
            }]
        }
    }
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
        
        DispatchQueue.main.async {
            self.delegate?.updateDownloadInformation(self, entity: downloadServiceType)
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
        
        DispatchQueue.main.async {
            self.delegate?.didEndDownloading(self, entity: downloadServiceType)
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
