//
//  DownloadService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 01.11.2021.
//

import Foundation

class DownloadService {
    var downloadsSession: URLSession!
    
    private(set) var activeDownloads: [URL: PodcastDownload] = [:]
    
    func startDownload(_ podcast: Podcast, indexPath: IndexPath) {
        guard let url = podcast.previewUrl.url,
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
//            print("FAILED DELETEING VIDEO DATA \(err.localizedDescription)")
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
