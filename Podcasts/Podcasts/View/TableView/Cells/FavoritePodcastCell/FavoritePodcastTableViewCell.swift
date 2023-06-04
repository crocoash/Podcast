//
//  TableViewCell.swift
//  Podcasts
//
//  Created by Anton on 31.05.2023.
//

import UIKit

protocol FavoritePodcastTableViewCellType {
    var mainImageForFavoritePodcastTableViewCellType: String? { get }
    var nameLabel: String? { get }
}

class FavoritePodcastTableViewCell: UITableViewCell {

    @IBOutlet private weak var collectionImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    private(set) var favoritePodcastTableViewCellType: FavoritePodcastTableViewCellType!
    
    func configureCell(with entity: FavoritePodcastTableViewCellType) {
        self.favoritePodcastTableViewCellType = entity
        DataProvider.shared.downloadImage(string: entity.mainImageForFavoritePodcastTableViewCellType) {
            self.collectionImageView.image = $0
        }
        self.nameLabel.text = entity.nameLabel
    }
}
