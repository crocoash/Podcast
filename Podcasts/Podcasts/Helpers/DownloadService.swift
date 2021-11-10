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

        var podcast = podcast
        podcast.index = index
        podcast.task = downloadsSession.downloadTask(with: url)
        podcast.task?.resume()
        activeDownloads[url] = podcast
    }
}
