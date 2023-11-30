//
//  BigPlayerViewModel.swift
//  Podcasts
//
//  Created by Anton on 19.09.2023.
//

import UIKit

//protocol BigPlayerPlayableProtocol {
// 
//
//}

protocol BigPlayerInputType {
    var id: String { get }
    var trackName: String? { get }
    var imageForBigPlayer: String? { get }
    var currentTime: Float? { get }
    var duration: Double? { get }
    var listeningProgress: Double? { get }
    var isGoingPlaying: Bool { get }
    var isLast: Bool { get }
    var isFirst: Bool { get }
    var isPlaying: Bool { get }
}

class BigPlayerViewModel: IPerRequest, IViewModelUpdating, INotifyOnChanged {

    struct Arguments {
        var input: BigPlayerInputType
    }
    
    /// Servisices
    private let likeManager: LikeManager
    private let player: Player
    private let listeningManager: ListeningManager
    
    var input: any BigPlayerInputType
    
    ///Track
    var isGoingPlaying: Bool { input.isGoingPlaying }
    var isLast: Bool { input.isLast }
    var isFirst: Bool { input.isFirst }
    var isPlaying: Bool { input.isPlaying }
    var id: String { input.id }
    var trackName: String? { input.trackName }
    var imageForBigPlayer: UIImage?
    var currentTime: Float? { input.currentTime }
    var duration: Double? { input.duration }
    var listeningProgress: Double? { input.listeningProgress }
    
    required init(container: IContainer, args: Arguments) {
        self.player = container.resolve()
        self.likeManager = container.resolve()
        self.input = args.input
        self.listeningManager = container.resolve()
        
        DataProvider.shared.downloadImage(string: args.input.imageForBigPlayer) { [weak self] image in
            guard let self = self else { return }
            imageForBigPlayer = image
        }
        
        player.delegate = self
        listeningManager.delegate = self
    }
    
    func update(with input: Any) {
    
        switch input {
        case let track as BigPlayerInputType:
            guard track.id == id else { return }
            self.input = track
            changed.raise()
        case let listeningPodcast as ListeningPodcast:
            guard listeningPodcast.podcast.id == id else { return }
            
            changed.raise()
        default:
            return
        }
        
    }
}

//extension List

//MARK: - PlayerEventNotification
extension BigPlayerViewModel: PlayerDelegate, ListeningManagerDelegate {}
