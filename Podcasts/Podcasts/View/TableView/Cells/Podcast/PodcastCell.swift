//
//  PodcastCell.swift
//  Podcasts
//
//  Created by student on 26.10.2021.
//

import UIKit

//MARK: - PodcastCell
class PodcastCell: UITableViewCell, IHaveViewModel {
    
  
    typealias ViewModel = PodcastCellViewModel
    
    func viewModelChanged(_ viewModel: PodcastCellViewModel) {
        
    }
    
    func viewModelChanged() {
        updateCell()
        configureGestures()
        self.heightOfImageView.constant = (frame.height - dateLabel.frame.height) - 10
    }
    
    @IBOutlet private weak var podcastImage:             UIImageView!
    @IBOutlet private weak var favouriteStarImageView:    UIImageView!
    @IBOutlet private weak var downLoadImageView:        UIImageView!
    @IBOutlet private weak var playStopButton:           UIImageView!
    @IBOutlet private weak var openDescriptionImageView: UIImageView!
    
    @IBOutlet private weak var podcastName:           UILabel!
    @IBOutlet private weak var downloadProgressLabel: UILabel!
    @IBOutlet private weak var podcastDescription:    UILabel!
    @IBOutlet private weak var trackDuration:         UILabel!
    @IBOutlet private weak var dateLabel:             UILabel!
    
    @IBOutlet private weak var downloadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var playerActivityIndicator:   UIActivityIndicatorView!
    
    @IBOutlet private weak var listeningProgressView: UIProgressView!
    @IBOutlet private weak var downloadProgressView:  UIProgressView!
    
    @IBOutlet private weak var heightOfImageView: NSLayoutConstraint!
    
    private let pauseImage = UIImage(systemName: "pause.circle.fill")!
    private let playImage = UIImage(systemName: "play.circle.fill")!
    private let downImage = UIImage(systemName: "chevron.down")!
    private let upImage = UIImage(systemName: "chevron.up")!
    
    private let isFavouriteImage = UIImage(named: "star5")!
    private let isNotFavouriteImage = UIImage(named: "star1")!
    
    
    var moreThanThreeLines: Bool {
        return podcastDescription.maxNumberOfLines > 3
    }
    
    private var defaultHeight: CGFloat = 50
    
    override var isSelected: Bool {
        didSet {
            updateSelectState()
        }
    }

    
    //MARK: Actions
    @objc func handlerTapFavouriteStar(_ sender: UITapGestureRecognizer) {
        viewModel.addOrRemoveFromFavourite()
    }
    
    @objc func tapPlayPauseButton(_ sender: UITapGestureRecognizer) {
        viewModel.playOrPause()
    }
    
    @objc func handlerTapDownloadImage(_ sender: UITapGestureRecognizer) {
        viewModel.download()
    }
}

//MARK: - Private Methods
extension PodcastCell {
    
    private func createImageArray(total: Int, imagePrafix: String) -> [UIImage] {
        var imageArray = [UIImage]()
        
        for i in 0..<total {
            let imageName = imagePrafix + "\(i+1)" + ".png"
            let image = UIImage(named: imageName)!
            imageArray.append(image)
        }
        return imageArray
    }
    
    func updateSelectState() {
        openDescriptionImageView.image = isSelected ? downImage : upImage
    }
    
    func updateFavouriteStar() {
        favouriteStarImageView.image = viewModel.isFavourite ? isFavouriteImage : isNotFavouriteImage
        updateDownloadUI()
    }
    
    func updatePlayerUI() {
        playStopButton.image = viewModel.isPlaying ? pauseImage : playImage
        playStopButton.isHidden = viewModel.isGoingPlaying
        listeningProgressView.progress = Float(viewModel.listeningProgress ?? 0)
        listeningProgressView.isHidden = viewModel.listeningProgress == nil
        
        if viewModel.isGoingPlaying {
            playerActivityIndicator.startAnimating()
        } else {
            playerActivityIndicator.stopAnimating()
        }
        
        playerActivityIndicator.isHidden = !viewModel.isGoingPlaying
    }
    
    func updateDownloadUI() {
        
        let isFavourite = viewModel.isFavourite
        
        let isDownloaded = viewModel.isDownloaded
        let isGoingDownload = viewModel.isGoingDownload
        let isDownloading  = viewModel.isDownloading
        
        if isFavourite {
            downloadProgressView.isHidden = !viewModel.isDownloading  ///+++
            downloadActivityIndicator.isHidden = !viewModel.isGoingDownload ///+++
            downLoadImageView.isHidden = isGoingDownload
            downloadProgressLabel.isHidden = !isDownloading
            
            downloadProgressView.progress = viewModel.downloadingProgress
            downloadProgressLabel.text = String(format: "%.1f%% of %@", viewModel.downloadingProgress * 100, viewModel.downloadTotalSize)
            downLoadImageView.image = UIImage(systemName: isDownloaded ? "checkmark.icloud.fill" : "icloud.and.arrow.down")
            
            if isGoingDownload {
                downloadActivityIndicator.startAnimating()
            } else {
                downloadActivityIndicator.stopAnimating()
            }
            
        } else {
            downloadProgressView.isHidden = true
            downloadActivityIndicator.isHidden = true
            downLoadImageView.isHidden = true
            downloadProgressLabel.isHidden = true
            downloadActivityIndicator.stopAnimating()
        }
    }
    
    private func updateCell() {
        dateLabel.text = viewModel.dateDuration
        trackDuration.text = viewModel.trackDuration
        podcastDescription.text = viewModel.descriptionMy
        podcastName.text = viewModel.trackName
        podcastImage.image = viewModel.imageForPodcastCell
        updateOpenDescriptionInfo()
        updateSelectState()
        updatePlayerUI()
        updateFavouriteStar()
        updateDownloadUI()
    }

    private func updateOpenDescriptionInfo() {
        podcastDescription.numberOfLines = podcastDescription.maxNumberOfLines
        openDescriptionImageView.isHidden = !moreThanThreeLines
    }
    
    private func configureGestures() {
        downLoadImageView.addMyGestureRecognizer(self, type: .tap(), #selector(handlerTapDownloadImage))
        playStopButton.addMyGestureRecognizer(self, type: .tap(), #selector(tapPlayPauseButton))
        favouriteStarImageView.addMyGestureRecognizer(self, type: .tap(), #selector(handlerTapFavouriteStar))
    }
}
