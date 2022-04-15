//
//  DownloadService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 01.11.2021.
//

import Foundation

class DownloadService {
    var downloadsSession: URLSession!
    
    var activeDownloads: [URL: PodcastDownload] = [:]
    
    func startDownload(_ podcast: Podcast, indexPath: IndexPath) {
        
        guard let url = podcast.previewUrl.url else { return }
        
        if activeDownloads[url] == nil {
            let podcastDownload = PodcastDownload(podcast: podcast,indexPath: indexPath, task: downloadsSession.downloadTask(with: url))
            podcastDownload.task?.resume()
            activeDownloads[url] = podcastDownload
        } else {
            activeDownloads[url]?.task?.cancel()
            activeDownloads[url] = nil
        }
    }
}

struct PodcastDownload {
    let podcast: Podcast
    let indexPath: IndexPath
    let task: URLSessionDownloadTask?
}
