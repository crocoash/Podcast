//
//  TableViewCell.swift
//  Podcasts
//
//  Created by Anton on 22.07.2023.
//

import UIKit

//MARK: - Input protocol
//protocol ListeningPodcastCellProtocol {
//    var id: String { get }
//    var duration: Double? { get }
//    var listeningProgress: Double? { get }
//    var imageForCell: String? { get }
//    var podcastName: String? { get }
//}

//MARK: - PlayableProtocol
protocol ListeningPodcastCellPlayableProtocol: Identifiable {
    var id: String { get }
    var listeningProgress: Double? { get }
    var duration: Double? { get }
}

struct ListeningPodcastCellModel: ListeningPodcastCellPlayableProtocol {
    
    var id: String
    var listeningProgress: Double?
    var duration: Double?
    var podcastName: String?
    var image: String?
    
    init(_ input: ListeningPodcast) {
        
        self.image = input.podcast.image600
        self.podcastName = input.podcast.trackName
        self.duration = input.duration
        self.listeningProgress = input.progress
        self.id = input.podcast.id
       
        self.id = input.id
    }
    
    mutating func updateModel(_ input: Any) {
        
        if let player = input as? any ListeningPodcastCellPlayableProtocol {
            
            if player.id == id {
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
    
    private(set) var model: ListeningPodcastCellModel! {
        didSet {
            updateCell()
        }
    }
    
    func configure(with model: ListeningPodcastCellModel ) {
        self.model = model
    }
    
    func update(with entity: Any) {
        
        if let input = entity as? ListeningPodcastCellModel {
            self.model = input
        } else {
            model.updateModel(entity)
        }
    }
}

//MARK: - Private Methods
extension ListeningPodcastCell {
    
    private func updateCell() {
        self.progressView.progress = Float(model.listeningProgress ?? 0)
        self.name.text = model.podcastName
        DataProvider.shared.downloadImage(string: model.image) {
            self.listeningImageView.image = $0
        }
    }
}
