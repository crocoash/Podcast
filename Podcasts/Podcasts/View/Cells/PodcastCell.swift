//
//  PodcastCell.swift
//  Podcasts
//
//  Created by student on 26.10.2021.
//

import UIKit

class PodcastCell: UITableViewCell {
    
    @IBOutlet private weak var podcastImage: UIImageView!
    @IBOutlet private weak var podcastName: UILabel!
    @IBOutlet private weak var playlistStarImageView: UIImageView!
    
}

extension PodcastCell {
    
    func configureCell(with podcast: Podcast) {
        podcastImage.image = nil
        
        backgroundColor = .white
        podcastName.text = podcast.trackName
        
        DataProvider().downloadImage(string: podcast.artworkUrl160) { [weak self] image in
            self?.podcastImage.image = image
        }
        
        playlistStarImageView.isHidden = !PlaylistDocument.shared.playList.contains(podcast)
    }
}
