//
//  SearchCollectionViewCell.swift
//  Podcasts
//
//  Created by Anton on 10.05.2023.
//

import UIKit

protocol SearchCollectionViewCellType {
    var mainImageForSearchCollectionViewCell: String? { get }
}

class SearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var podcastImageView: UIImageView!
    
    private var entity: SearchCollectionViewCellType!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        podcastImageView.image = nil    
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUP(entity: SearchCollectionViewCellType) {
        self.entity = entity
        DataProvider.shared.downloadImage(string: entity.mainImageForSearchCollectionViewCell) {
            self.podcastImageView.image = $0
        }
    }
}
