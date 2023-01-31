//
//  DownloadService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 01.11.2021.
//

import UIKit

class DownloadService {
    var downloadsSession: URLSession!
    
    private(set) var activeDownloads: [URL: PodcastDownload] = [:]
    
    func startDownload(_ podcast: Podcast) {
        
        if !NetworkMonitior.shared.isConnection {
            Alert().create(title: "No Internet") { _ in
                [UIAlertAction(title: "Ok", style: .cancel)]
            }
            return
        } else if NetworkMonitior.shared.connectionType == .cellular {
            let vc = UIApplication.shared.windows.first?.rootViewController
            Alert().create(title: "Used Mobile intertnet for downLoad? ") { _ in
                [ UIAlertAction(title: "Now", style: .cancel) { _ in
                    vc?.dismiss(animated: true)
                    return
                }, UIAlertAction(title: "Yes", style: .default) { _ in
                    vc?.dismiss(animated: true)
                }]
            }
        }
        
        guard let url = podcast.episodeUrl.url,
              let id = podcast.id else { return }
        
        if activeDownloads[url] == nil {
            let podcastDownload = PodcastDownload(id: id, task: downloadsSession.downloadTask(with: url))
            podcastDownload.task?.resume()
            activeDownloads[url] = podcastDownload
        }
    }
    
    func resumeDownload(_ podcast: Podcast) {
        guard let url = podcast.previewUrl.url else { return }
        activeDownloads[url]?.task?.resume()
    }
    
    func cancelDownload(podcast: Podcast) {
        guard let url = podcast.previewUrl.url else { return }
        activeDownloads[url]?.task?.cancel()
        activeDownloads[url] = nil

        do {
            try FileManager.default.removeItem(at: url.localPath)
        } catch (let err) {
            fatalError(err.localizedDescription)
        }
    }
    
    func endDownload(url: URL) {
        activeDownloads[url] = nil
    }
}

struct PodcastDownload {
    let id: NSNumber
    let task: URLSessionDownloadTask?
}
