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
    
    func startDownload(_ podcast: Podcast, index: Int) {
        
        guard let stringUrl = podcast.previewUrl,
              let url = URL(string: stringUrl) else { return }
        
        if activeDownloads[url] == nil {
            let podcastDownload = PodcastDownload(podcast: podcast, task: downloadsSession.downloadTask(with: url))
            podcast.index = NSNumber(value: index)
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
    let task: URLSessionDownloadTask?
}
