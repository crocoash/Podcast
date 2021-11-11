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
    @IBOutlet private weak var progressLabel: UILabel!
    @IBOutlet private weak var downloadProgressView: UIProgressView!
    @IBOutlet private weak var isDownLoadImageView: UIImageView!
}

extension PodcastCell {
    
    func configureCell(with podcast: Podcast) {
        podcastImage.image = nil
        
        downloadProgressView.isHidden = true
        progressLabel.isHidden = true 
        
        podcastName.text = podcast.trackName
        
        DataProvider().downloadImage(string: podcast.artworkUrl160) { [weak self] image in
            self?.podcastImage.image = image
        }
        
        isDownLoadImageView.isHidden = !PlaylistDocument.shared.podcastIsDownload(podcast: podcast)
        
        playlistStarImageView.isHidden = !PlaylistDocument.shared.podcastIsFavorite(podcast: podcast)
    }
    
    func updateDisplay(progress: Float, totalSize : String) {
        if downloadProgressView.isHidden { downloadProgressView.isHidden = false }
        if progressLabel.isHidden { progressLabel.isHidden = false }
        
        downloadProgressView.progress = progress
        progressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
    }
}
