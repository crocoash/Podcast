//
//  DownloadService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 01.11.2021.
//

import Foundation

class DownloadService {
    var downloadsSession: URLSession!
    
    var activeDownloads: [URL: Download] = [:]
    
    func startDownload(_ podcast: Podcast) {
        let download = Download(podcast: podcast)
        
        guard let stringUrl = podcast.previewUrl, let url = URL(string: stringUrl) else { return }
        
        download.task = downloadsSession.downloadTask(with: url)
        download.task?.resume()
        download.isDownloading = true
        activeDownloads[url] = download
    }
}

class Download {
    
    // MARK: - Variables And Properties
    var isDownloading = false
    var progress: Float = 0
    var resumeData: Data?
    var task: URLSessionDownloadTask?
    var podcast: Podcast
    
    // MARK: - Initialization
    init(podcast: Podcast) {
        self.podcast = podcast
    }
}
