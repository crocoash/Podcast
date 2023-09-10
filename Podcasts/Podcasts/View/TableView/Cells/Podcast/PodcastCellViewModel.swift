//
//  File.swift
//  Podcasts
//
//  Created by Anton on 10.09.2023.
//

import Foundation

//MARK: - PlayableProtocol
protocol PodcastCellPlayableProtocol {
    var isPlaying: Bool { get }
    var isGoingPlaying: Bool { get }
    var listeningProgress: Double? { get }
    var duration: Double? { get }
    var trackId: String { get }
}

protocol PodcastCellDownloadProtocol {
    var downloadId: String { get }
    var isDownloading: Bool { get }
    var isDownloaded: Bool { get }
    var isGoingDownload: Bool { get }
    var downloadingProgress: Float  { get }
    var downloadTotalSize : String  { get }
}

protocol UpdatingTypes: PodcastCellDownloadProtocol, PodcastCellPlayableProtocol {}

class PodcastCellViewModel: UpdatingTypes {
    
    var id: String
    var isFavourite: Bool 
    var trackDuration: String? 
    var dateDuration: String 
    var descriptionMy: String? 
    var trackName: String? 
    var imageForPodcastCell: String? 
    var listeningProgress: Double?
    
    ///DownloadServiceInformation
    var downloadId: String
    var downloadingProgress: Float = 0 

    var isDownloading: Bool 
    var isGoingDownload: Bool 
    var downloadTotalSize : String = "" 
    var isDownloaded: Bool
    
    ///Player
    var isPlaying: Bool = false 
    var isGoingPlaying: Bool = false 
    
    var duration: Double? 
    var trackId: String
    
    init(podcast: Podcast) {
        
        self.id = podcast.id
        self.isFavourite = podcast.isFavourite
        self.trackDuration = podcast.trackDuration
        self.dateDuration = podcast.dateDuration
        self.descriptionMy = podcast.descriptionMy
        self.trackName = podcast.trackName
        self.imageForPodcastCell = podcast.imageForPodcastCell
        self.listeningProgress = podcast.listeningProgress
        
        self.trackId = podcast.id
        self.downloadId = podcast.id
        self.downloadingProgress = 0
        self.isDownloading = false
        self.isGoingDownload = false
        self.downloadTotalSize = ""
        self.isDownloaded = false
        self.isPlaying = false
        self.isGoingPlaying = false
        self.duration =  0
    }
}


extension PodcastCellViewModel {
    
}
