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
//        DataProvider.cancellDownLoad(url: )
        
    }

    
    @IBAction func handlerTapFavoriteStar(_ sender: UIButton) {
        if !self.isFavorite {
            let imageArray = self.createImageArray(total: 5, imagePrafix: "star")
            favoriteStarImageView.animationImages = imageArray
            favoriteStarImageView.animationDuration = 1.0
            favoriteStarImageView.animationRepeatCount = 1
            favoriteStarImageView.startAnimating()
            
            Timer.scheduledTimer(withTimeInterval: 0.9, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.podcastCellDidSelectStar(self, podcast: self.podcast)
            }
        } else {
            delegate?.podcastCellDidSelectStar(self, podcast: podcast)
        }
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
    
    func configureCell(with podcast: Podcast) {         self.podcast = podcast
        downLoadImageView.addMyGestureRecognizer(self, type: .tap(), #selector(handlerTapDownloadImage))

        /// information from favorite tab
        isDownLoad = FavoriteDocument.shared.isDownload(podcast)
        isFavorite =  FavoriteDocument.shared.isFavorite(podcast)

        downLoadImageView.isHidden = !isFavorite
        
        if podcast.episodeUrl != nil {
            downLoadImageView.image = UIImage(systemName: isDownLoad ? "checkmark.icloud.fill" : "icloud.and.arrow.down")
        } else {
            downLoadImageView.isHidden = true
        }
        downloadProgressView?.isHidden = true
        progressLabel.isHidden = true
        
        favoriteStarImageView.image = UIImage(named: isFavorite ? "star5" : "star1")
        
        podcastName.text = podcast.trackName
        podcastImage.image = nil
        DataProvider.shared.downloadImage(string: podcast.artworkUrl600) { [weak self] image in
            self?.podcastImage.image = image
        }
    }
    
    func updateDisplay(progress: Float, totalSize : String) {
        
        if !activityIndicator.isHidden { activityIndicator.isHidden = true }
        if downLoadImageView.isHidden { downLoadImageView.isHidden = false }
        if downloadProgressView.isHidden { downloadProgressView.isHidden = false }
        if progressLabel.isHidden { progressLabel.isHidden = false }
        
        downloadProgressView.progress = progress
        progressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
    }
    
    private func createImageArray(total: Int, imagePrafix: String) -> [UIImage] {
        var imageArray = [UIImage]()
        
        for i in 0..<total {
            let imageName = imagePrafix + "\(i+1)" + ".png"
            let image = UIImage(named: imageName)!
            imageArray.append(image)
        }
        return imageArray
    }
}
