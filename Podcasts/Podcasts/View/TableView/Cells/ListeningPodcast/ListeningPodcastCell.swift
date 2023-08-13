//
//  TableViewCell.swift
//  Podcasts
//
//  Created by Anton on 22.07.2023.
//

import UIKit

protocol ListeningPodcastCellProtocol {
    var id: String { get }
    var progressForCell: Float { get }
    var imageForCell: String? { get }
    var podcastName: String? { get }
}

//MARK: - PlayableProtocol
protocol ListeningPodcastCellPlayableProtocol {
    var trackId: String { get }
    var listeningProgress: Double? { get }
    var duration: Double? { get }
}

struct ListeningPodcastCellModel: ListeningPodcastCellProtocol, ListeningPodcastCellPlayableProtocol {
    var id: String
    var listeningProgress: Double?
    var duration: Double?
    var trackId: String
    var podcastName: String?
    var imageForCell: String?
    var progressForCell: Float
    
    init(_ input: ListeningPodcastCellProtocol) {
        self.progressForCell = input.progressForCell
        self.imageForCell = input.imageForCell
        self.podcastName = input.podcastName
        self.trackId = input.id
        self.id = input.id
    }
    
    mutating func updateModel(_ input: Any) {
        
        if let player = input as? ListeningPodcastCellPlayableProtocol {
            
            if player.trackId == trackId {
                self.listeningProgress = player.listeningProgress
                self.duration = player.duration
            }
        }
    }
}

class ListeningPodcastCell: UITableViewCell {
    
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var listeningImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private(set) var model: ListeningPodcastCellModel!
    
    func configure(with model: ListeningPodcastCellProtocol ) {
        self.progressView.progress = model.progressForCell
        self.name.text = model.podcastName
        DataProvider.shared.downloadImage(string: model.imageForCell) {
            self.listeningImageView.image = $0
        }
    }
    
    func update(with entity: Any) {
        model.updateModel(entity)
    }
}
