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

class LikedPodcastTableViewCell: UITableViewCell {

    @IBOutlet private weak var collectionImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    private(set) var favouritePodcastTableViewCellType: LikedPodcastTableViewCellType!
    
    func configureCell(with entity: LikedPodcastTableViewCellType) {
        self.favouritePodcastTableViewCellType = entity
        DataProvider.shared.downloadImage(string: entity.mainImageForFavouritePodcastTableViewCellType) {
            self.collectionImageView.image = $0
        }
        self.nameLabel.text = entity.nameLabel
    }
}
