//
//  File.swift
//  Podcasts
//
//  Created by Anton on 10.09.2023.
//

import UIKit

//MARK: - Delegate

//MARK: - PlayableProtocol
protocol PodcastCellPlayableProtocol: Identifiable {
    var id: String { get }
    var isPlaying: Bool { get }
    var isGoingPlaying: Bool { get }
    var listeningProgress: Double? { get }
    var duration: Double? { get }
}

protocol PodcastCellDownloadProtocol: Identifiable {
    var id: String { get }
    var isDownloading: Bool { get }
    var isDownloaded: Bool { get }
    var isGoingDownload: Bool { get }
    var downloadingProgress: Float  { get }
    var downloadTotalSize : String  { get }
}

protocol IPodcastCell: Identifiable, PodcastCellDownloadProtocol, PodcastCellPlayableProtocol, IViewModelUpdating {}

class PodcastCellViewModel: IPerRequest, INotifyOnChanged, IPodcastCell {
    
    struct Input {
        let podcast: Podcast
        let playlist: [Podcast]
    }
    
    typealias Arguments = Input
    
    let podcast: Podcast
    let podcasts: [Podcast]
    
    //MARK: Services
    let listeningManager: ListeningManager
    let favouriteManager: FavouriteManager
    let player: Player
    let downloadService: DownloadService
    let dataStoreManager: DataStoreManager
    
    var id: String { podcast.id }
    var dateDuration: String = "args.dateDuration"
    var descriptionMy: String { podcast.descriptionMy ?? "" }
    var trackName: String? { podcast.trackName }
    var imageForPodcastCell: UIImage?
    
    ///Listening
    var listeningProgress: Double? { podcast.listeningProgress }
    var trackDuration: String { podcast.trackTimeMillis?.minute ?? "" }

    ///Favourite
    var isFavourite: Bool

    ///DownloadServiceInformation
    var downloadingProgress: Float = 0
    var isDownloading: Bool
    var isGoingDownload: Bool
    var downloadTotalSize : String = ""
    var isDownloaded: Bool
    
    ///Player
    private(set) var isPlaying: Bool
    var isGoingPlaying: Bool
    var duration: Double?
    
    required init(container: IContainer, args input: Input) {
        self.podcast = input.podcast
        self.podcasts = input.playlist
        
        ///dataStoreManager
        self.dataStoreManager = container.resolve()
        
        ///listeningManager
        self.listeningManager = container.resolve()
//        self.listeningProgress = input.podcast.listeningProgress
        
        ///Favourite
        self.favouriteManager = container.resolve()
        self.isFavourite = favouriteManager.isFavourite(podcast)
        
        self.player = container.resolve()
        self.isPlaying = player.isCurrentTrack(podcast) && player.isPlaying
        self.isGoingPlaying = player.isCurrentTrack(podcast) && player.isLoading
        
        ///download
        self.downloadService = container.resolve()
        self.isDownloading =  downloadService.isDownloading(entity: podcast)
        self.isGoingDownload = downloadService.isGoingDownload(entity: podcast)
        self.downloadingProgress = downloadService.downloadProgress(for: podcast)
        self.isDownloaded = downloadService.isDownloaded(entity: podcast)
        
        DataProvider.shared.downloadImage(string: podcast.artworkUrl600) { [weak self] image in
            guard let self = self else { return }
            imageForPodcastCell = image
            changed.raise()
        }
        
        confiureDelegates()
    }
    
   
    func download() {
        downloadService.conform(entity: podcast)
    }
    
    func playOrPause() {
        player.conform(track: podcast, trackList: podcasts)
    }
    
    func addOrRemoveFromFavourite() {
        if isFavourite {
            favouriteManager.removeFavouritePodcast(podcast: podcast)
        } else {
            favouriteManager.addFavouritePodcast(podcast: podcast)
        }
    }
}

//MARK: - Private Methods
extension PodcastCellViewModel {
    
    func update(with input: Any) {
                
        switch input {
        case let favouritePodcast as FavouritePodcast:
            if favouritePodcast.podcast.id == podcast.id {
                isFavourite = favouritePodcast.podcast.favouritePodcast != nil
            }
            /// PodcastCellPlayableProtocol
        case let player as any PodcastCellPlayableProtocol:
            
            if player.id == id {
                isPlaying = player.isPlaying
                isGoingPlaying = player.isGoingPlaying
            }
            /// PodcastCellDownloadProtocol
        case let download as any PodcastCellDownloadProtocol:
            
            if download.id == id {
                isDownloaded = download.isDownloaded
                isDownloading  = download.isDownloading
                isGoingDownload = download.isGoingDownload
                downloadingProgress = download.downloadingProgress
                downloadTotalSize = download.downloadTotalSize
            }
            /// ListeningPodcast
        case var listeningPodcast as ListeningPodcast:
            
            if listeningPodcast.podcast.id == id {
                podcast.setValue(value: listeningPodcast)
            }
        default:
            return
        }
        changed.raise()
    }
    
    private func confiureDelegates() {
        listeningManager.delegate = self
        favouriteManager.delegate = self
        player.delegate = self
        downloadService.delegate = self
    }
}

//MARK: - Delegates
extension PodcastCellViewModel: PlayerDelegate, DownloadServiceDelegate, ListeningManagerDelegate, FavouriteManagerDelegate {}
 
