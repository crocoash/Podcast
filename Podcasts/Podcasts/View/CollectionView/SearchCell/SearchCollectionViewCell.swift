//
//  SearchCollectionViewCell.swift
//  Podcasts
//
//  Created by Anton on 10.05.2023.
//

import UIKit

protocol SearchCollectionViewCellType {
    var image: String? { get }
}

class SearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var podcastImageView: UIImageView!
    
    private var entity: SearchCollectionViewCellType!
    
    func setUP(entity: SearchCollectionViewCellType) {
        self.entity = entity
        
        DataProvider.shared.downloadImage(string: entity.image) { [weak self] image in
            self?.podcastImageView.image = image
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
