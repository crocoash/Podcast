//
//  TableViewCell.swift
//  Podcasts
//
//  Created by Anton on 31.05.2023.
//

import UIKit

protocol LikedPodcastTableViewCellType {
    var mainImageForFavouritePodcastTableViewCellType: String? { get }
    var nameLabel: String? { get }
}

class LikedPodcastTableViewCellModel {
    
    var image: String?
    var nameLabel: String?
    
    init(likedMoment: LikedMoment) {
        self.image = likedMoment.podcast.image600
        self.nameLabel = likedMoment.podcast.trackName
    }
}
 
class LikedPodcastTableViewCell: UITableViewCell {

    @IBOutlet private weak var collectionImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
  
    func configureCell(with entity: LikedPodcastTableViewCellModel) {
        DataProvider.shared.downloadImage(string: entity.image) {
            self.collectionImageView.image = $0
        }
        self.nameLabel.text = entity.nameLabel
    }
}
