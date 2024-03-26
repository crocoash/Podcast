//
//  SearchCollectionViewCell.swift
//  Podcasts
//
//  Created by Anton on 10.05.2023.
//

import UIKit


class SearchCollectionViewCell: UICollectionViewCell {
    
   @IBOutlet private weak var podcastName: UILabel!
   @IBOutlet private weak var podcastImageView: UIImageView!
    
    private var entity: Podcast!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        podcastImageView.image = nil
        if let entity = entity {
            DataProvider.shared.cancelDownload(string: entity.artworkUrl600 ?? "")
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUP(podcast: Podcast) {
        
        self.entity = podcast
       podcastName.text = podcast.wrapperType
        DataProvider.shared.downloadImage(string: entity.artworkUrl600) { [weak self] in
            guard let self = self else { return }
            podcastImageView.image = $0
        }
    }
}
