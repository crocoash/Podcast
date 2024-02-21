//
//  SmallPlayerViewModel.swift
//  Podcasts
//
//  Created by Anton on 19.09.2023.
//

import UIKit

protocol SmallPlayerInputType {
    var imageForSmallPlayer: String { get }
    var trackName: String? { get }
    var id: String { get }
    var listeningProgress: Double? { get }
    var isGoingPlaying: Bool { get }
    var isPlaying: Bool { get }
}

class SmallPlayerViewModel: IPerRequest, INotifyOnChanged, IViewModelUpdating {
    
    typealias Arguments = Input
    
    struct Input {
        var item: any SmallPlayerInputType
    }
    
    private var item: any SmallPlayerInputType {
        didSet {
            if oldValue.imageForSmallPlayer != item.imageForSmallPlayer || image == nil {
                DataProvider.shared.downloadImage(string: item.imageForSmallPlayer) { [weak self] image in
                    guard let self = self else { return }
                    self.image = image
                    changed.raise()
                }     
            }
        }
    }
    
    ///Services
    let container: IContainer
    let player: Player
    
    ///Player
    private(set) var isGoingPlaying: Bool = true
    private(set) var isPlaying: Bool = false
    
    var listeningProgress: Double? { item.listeningProgress }
    var imageForSmallPlayer: String? { item.imageForSmallPlayer }
    private(set) var image: UIImage?
    
    var trackName: String? { item.trackName }
    var id: String { item.id }
    
    //MARK: init
    required init?(container: IContainer, args input: Arguments) {
        
        self.player = container.resolve()
        self.container = container
        
        item = input.item
        
        player.delegate = self
    }
    
    func update(with input: Any) {
        switch input {
        case let item as SmallPlayerInputType:
            self.item = item
            self.isPlaying = item.isPlaying
            self.isGoingPlaying = item.isGoingPlaying
            changed.raise()
            
        default:
            return
        }
    }
}

//MARK: - Delgates
extension SmallPlayerViewModel: PlayerDelegate {}
