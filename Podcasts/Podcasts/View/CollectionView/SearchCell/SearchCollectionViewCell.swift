//
//  SearchCollectionViewCell.swift
//  Podcasts
//
//  Created by Anton on 10.05.2023.
//

import UIKit


class SearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var podcastImageView: UIImageView!
    
    private var entity: Podcast!
    
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
    
    func setUP(podcast: Podcast) {
        self.entity = podcast
        DataProvider.shared.downloadImage(string: podcast.artworkUrl160) { [weak self] in
            guard let self = self else { return }
            podcastImageView.image = $0
        }
    }
}
