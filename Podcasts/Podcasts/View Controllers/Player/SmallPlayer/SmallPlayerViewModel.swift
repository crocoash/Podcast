//
//  SmallPlayerViewModel.swift
//  Podcasts
//
//  Created by Anton on 19.09.2023.
//

import Foundation

protocol SmallPlayerPlayableProtocol {
    var imageForSmallPlayer: String? { get }
    var trackName: String? { get }
    var listeningProgress: Double? { get }
    var isPlaying: Bool { get }
    var isGoingPlaying: Bool { get }
    var id: String { get }
}

class SmallPlayerViewModel: SmallPlayerPlayableProtocol, INotifyOnChanged, IViewModelUpdating {
   
    
    var isGoingPlaying: Bool = true
    var imageForSmallPlayer: String?
    var trackName: String?
    var listeningProgress: Double?
    var isPlaying: Bool = false
    var id: String
    
    //MARK: init
    init(_ entity: SmallPlayerPlayableProtocol) {
        self.imageForSmallPlayer = entity.imageForSmallPlayer
        self.trackName = entity.trackName
        self.listeningProgress = entity.listeningProgress
        self.id = entity.id
        self.imageForSmallPlayer = entity.imageForSmallPlayer
    }
    
    func update(with input: Any) {
        switch input {
        case let player as SmallPlayerPlayableProtocol:
            self.imageForSmallPlayer = player.imageForSmallPlayer
            self.trackName = player.trackName
            self.listeningProgress = player.listeningProgress
            self.isPlaying = player.isPlaying
            self.isGoingPlaying = player.isGoingPlaying
        default:
            return
        }
        changed.raise()
    }
}

//MARK: - Delgates
extension SmallPlayerViewModel: PlayerDelegate {}
