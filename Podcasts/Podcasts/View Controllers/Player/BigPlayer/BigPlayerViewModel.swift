//
//  BigPlayerViewModel.swift
//  Podcasts
//
//  Created by Anton on 19.09.2023.
//

import UIKit


class BigPlayerViewModel: IPerRequest, IViewModelUpdating, INotifyOnChanged {
    
    private let likeManager: LikeManager
    private let player: Player
    
    typealias Arguments = Track
    
    var track: Track
    
    var isGoingPlaying: Bool { track.isGoingPlaying }
    var isLast: Bool { track.isLast }
    var isFirst: Bool  { track.isFirst }
    var isPlaying: Bool { track.isPlaying }
    
    var id: String { track.id }
    var trackName: String? { track.trackName }
    var imageForBigPlayer: UIImage?
    var currentTime: Float? { track.currentTime }
    var duration: Double? { track.duration }
    var listeningProgress: Double? { track.listeningProgress }
    
    required init(container: IContainer, args track: Arguments) {
        self.player = container.resolve()
        self.likeManager = container.resolve()
        
        self.track = track
        
        DataProvider.shared.downloadImage(string: track.imageForBigPlayer) { [weak self] image in
            guard let self = self else { return }
            imageForBigPlayer = image
        }
    }
    
    func update(with input: Any) {
        
        switch input {
        case let track as Track:
            self.track = track
        default:
            return
        }
        changed.raise()
    }
    
    func addLikeMoment() {
//        likeManager.addToLikedMoments(entity: track, moment: podcast.listeningProgress ?? 0)
    }
}

//MARK: - PlayerEventNotification
extension BigPlayerViewModel: PlayerDelegate {}
