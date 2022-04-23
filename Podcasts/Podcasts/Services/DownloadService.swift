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
        guard let url = podcast.previewUrl.url else { return }
        
        if activeDownloads[url] == nil {
            let podcastDownload = PodcastDownload(podcast: podcast,indexPath: indexPath, task: downloadsSession.downloadTask(with: url))
            podcastDownload.task?.resume()
            activeDownloads[url] = podcastDownload
        }
    }
    
    func cancelDownload(podcast: Podcast) {
        guard let url = podcast.previewUrl.url else { return }
        activeDownloads[url]?.task?.cancel()
        activeDownloads[url] = nil
        
        do {
            try FileManager.default.removeItem(at: url.localPath)
        } catch (let err) {
            //TODO:
            fatalError(err.localizedDescription)
//            print("FAILED DELETEING VIDEO DATA \(err.localizedDescription)")
        }
    }
    
    func endDownload(url: URL) {
        activeDownloads[url] = nil
    }
}

struct PodcastDownload {
    let podcast: Podcast
    let indexPath: IndexPath
    let task: URLSessionDownloadTask?
}
