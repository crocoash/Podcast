//
//  PodcastCell.swift
//  Podcasts
//
//  Created by student on 26.10.2021.
//

import UIKit

protocol PodcastCellDelegate: AnyObject {
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell, podcast: Podcast)
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell, podcast: Podcast)
}

class PodcastCell: UITableViewCell {
    
    @IBOutlet private weak var podcastImage: UIImageView!
    @IBOutlet private weak var podcastName: UILabel!
    @IBOutlet private weak var favoriteStarImageView: UIImageView!
    @IBOutlet private weak var progressLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var downloadProgressView: UIProgressView!
    @IBOutlet private weak var downLoadImageView: UIImageView!
    
    weak var delegate: PodcastCellDelegate?
    private var podcast: Podcast!
    private var isDownLoad: Bool!
    private var isFavorite: Bool!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        podcastImage.image = nil
        downLoadImageView.image = nil
        downloadProgressView?.isHidden = true
        progressLabel.isHidden = true
    }
    
    @IBAction func handlerTapFavoriteStar(_ sender: UIButton) {
        delegate?.podcastCellDidSelectStar(self, podcast: podcast)
    }
    
    @objc func handlerTapDownloadImage(_ sender: UITapGestureRecognizer) {
        if !isDownLoad {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            downLoadImageView.isHidden = true
        }
        delegate?.podcastCellDidSelectDownLoadImage(self, podcast: podcast)
    }
}

extension PodcastCell {
    
    func configureCell(with podcast: Podcast) {
        self.podcast = podcast
      
        downLoadImageView.addMyGestureRecognizer(self, type: .tap(), selector: #selector(handlerTapDownloadImage))
                
        /// information from favorite tab
        isFavorite = podcast.isFavorite
        isDownLoad =  FavoriteDocument.shared.isDownload(podcast: podcast)
        
        downLoadImageView.isHidden = !isFavorite
        
        downLoadImageView.image = UIImage(systemName: isDownLoad ? "checkmark.icloud.fill" : "icloud.and.arrow.down")
        favoriteStarImageView.image = UIImage(systemName: isFavorite ? "star.fill" : "star")

        podcastName.text = podcast.trackName
        
        DataProvider().downloadImage(string: podcast.artworkUrl600) { [weak self] image in
            self?.podcastImage.image = image
        }
    }
    
    func updateDisplay(progress: Float, totalSize : String) {
        
        activityIndicator.isHidden = true
        downLoadImageView.isHidden = false
        
        if downloadProgressView.isHidden { downloadProgressView.isHidden = false }
        if progressLabel.isHidden { progressLabel.isHidden = false }
        
        downloadProgressView.progress = progress
        progressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
    }
}
