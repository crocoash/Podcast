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

class PodcastCellViewModel: IPerRequest, UpdatingTypes {
    
    let listeningManager: ListeningManager
    let favouriteManager: FavouriteManager
    
    typealias Arguments = Podcast
    
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
    
    required init(container: IContainer, args: Podcast) {
        self.id = args.id
        self.dateDuration = "args.dateDuration"
        self.descriptionMy = args.descriptionMy
        self.trackName = args.trackName
        self.imageForPodcastCell = args.image600
        self.listeningProgress = args.listeningProgress
        
        self.listeningManager = container.resolve()
        self.favouriteManager = container.resolve()
        
        let listeningPodcast = listeningManager
        
        self.trackId = args.id
        self.downloadId = args.id
        self.downloadingProgress = 0
        
        self.isDownloading = false
        self.isGoingDownload = false
        self.downloadTotalSize = ""
        self.isDownloaded = false
        self.isPlaying = false
        self.isGoingPlaying = false
        self.duration =  0
        self.trackDuration = "args.listeningPodcast?.duration"
        self.isFavourite = favouriteManager.isFavourite(args)
    }
}


extension PodcastCellViewModel {
    
}
