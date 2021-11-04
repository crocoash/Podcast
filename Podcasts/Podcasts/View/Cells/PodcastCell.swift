//
//  PodcastCell.swift
//  Podcasts
//
//  Created by student on 26.10.2021.
//

import UIKit

class PodcastCell: UITableViewCell, CustomTableViewCell {
    
    @IBOutlet private weak var podcastImage: UIImageView!
    @IBOutlet private weak var podcastName: UILabel!
    @IBOutlet private weak var collectionName: UILabel!
    
    var indexPath: IndexPath!
}

extension PodcastCell {
    
    func configureCell(with podcast: Podcast,_ indexPath: IndexPath) {
        self.indexPath = indexPath
        
        backgroundColor = .white
        podcastName.text = podcast.trackName
        podcastImage.load(string: podcast.artworkUrl160!)
        collectionName.text = podcast.collectionName
        
        if podcast.isAddToPlaylist { backgroundColor = .yellow }
    }
}
