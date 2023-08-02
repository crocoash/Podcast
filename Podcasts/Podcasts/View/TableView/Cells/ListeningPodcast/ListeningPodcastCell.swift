//
//  TableViewCell.swift
//  Podcasts
//
//  Created by Anton on 22.07.2023.
//

import UIKit

protocol ListeningPodcastCellProtocol {
    var progressForCell: Float { get }
    var imageForCell: String? { get }
    var podcastName: String? { get }
}

struct ListeningPodcastCellModel: ListeningPodcastCellProtocol {
    var podcastName: String?
    var imageForCell: String?
    var progressForCell: Float
    
    init(_ input: ListeningPodcastCellProtocol) {
        self.progressForCell = input.progressForCell
        self.imageForCell = input.imageForCell
        self.podcastName = input.podcastName
    }
}

class ListeningPodcastCell: UITableViewCell {
    
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var listeningImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    
    func configure(with model: ListeningPodcastCellProtocol ) {
        self.progressView.progress = model.progressForCell
        self.name.text = model.podcastName
        DataProvider.shared.downloadImage(string: model.imageForCell) {
            self.listeningImageView.image = $0
        }
    }
}
