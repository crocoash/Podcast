//
//  PodcastCell.swift
//  Podcasts
//
//  Created by student on 26.10.2021.
//

import UIKit

protocol PodcastCellDelegate: AnyObject {
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell)
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell, podcast: Podcast)
}

class PodcastCell: UITableViewCell {
    
    @IBOutlet private weak var podcastImage: UIImageView!
    @IBOutlet private weak var podcastName: UILabel!
    @IBOutlet private weak var favoriteStarImageView: UIImageView!
    @IBOutlet private weak var progressLabel: UILabel!
    @IBOutlet private weak var downloadProgressView: UIProgressView!
    @IBOutlet private weak var downLoadImageView: UIImageView!
    
    weak var delegate: PodcastCellDelegate?
    
    var podcast: Podcast!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        podcastImage.image = nil
        downloadProgressView.isHidden = true
        progressLabel.isHidden = true
    }
    
    @objc func handlerTapFavoriteStar(_ sender: UITapGestureRecognizer) {
        delegate?.podcastCellDidSelectStar(self)
    }
    
    @objc func handlerTapDownloadImage(_ sender: UITapGestureRecognizer) {
        delegate?.podcastCellDidSelectDownLoadImage(self, podcast: podcast)
    }
}

extension PodcastCell {
    
    func configureCell(with podcast: Podcast) {
        self.podcast = podcast
        favoriteStarImageView.addMyGestureRecognizer(self, type: .tap(), selector: #selector(handlerTapFavoriteStar))
        downLoadImageView.addMyGestureRecognizer(self, type: .tap(), selector: #selector(handlerTapDownloadImage))
        
        
        /// information from favorite tab
        let isDownload = Podcast.isDownload(podcast: podcast)
        let isFavorite = Podcast.podcastIsFavorite(podcast: podcast)
        downLoadImageView.isHidden = !(isDownload || podcast.isDownLoad || isFavorite)
       
        
        downLoadImageView.image = UIImage(systemName: podcast.isDownLoad || isDownload ? "checkmark.icloud.fill" : "icloud.and.arrow.down")
        favoriteStarImageView.image = UIImage(systemName: isFavorite || podcast.isFavorite ? "star.fill" : "star")

        podcastName.text = podcast.trackName
        
        DataProvider().downloadImage(string: podcast.artworkUrl160) { [weak self] image in
            self?.podcastImage.image = image
        }
    }
    
    func updateDisplay(progress: Float, totalSize : String) {
        downLoadImageView.image = UIImage(systemName: podcast.isDownLoad ? "checkmark.icloud.fill" : "icloud.and.arrow.down")
        if downloadProgressView.isHidden { downloadProgressView.isHidden = false }
        if progressLabel.isHidden { progressLabel.isHidden = false }
        
        downloadProgressView.progress = progress
        progressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
    }
}
