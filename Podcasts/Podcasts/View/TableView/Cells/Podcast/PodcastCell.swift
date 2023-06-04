//
//  PodcastCell.swift
//  Podcasts
//
//  Created by student on 26.10.2021.
//

import UIKit

//MARK: - Delegate
protocol PodcastCellDelegate: AnyObject {
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell)
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell)
    func podcastCellDidTouchPlayButton(_ podcastCell: PodcastCell)
    func podcastCellDidTouchStopButton(_ podcastCell: PodcastCell)
}


//MARK: - PlayableProtocol
protocol PodcastCellPlayableProtocol {
    var isPlaying: Bool { get }
    var progress: Double? { get }
}

//MARK: - PodcastCell
class PodcastCell: UITableViewCell {
    
    @IBOutlet private weak var podcastImage:             UIImageView!
    @IBOutlet private weak var favoriteStarImageView:    UIImageView!
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

    private let pauseImage = UIImage(systemName: "pause.circle.fill")!
    private let playImage = UIImage(systemName: "play.circle.fill")!
    private let downImage = UIImage(systemName: "chevron.down")!
    private let upImage = UIImage(systemName: "chevron.up")!
    
    var heightOfCell = CGFloat(100)
    
    weak var delegate: PodcastCellDelegate?
    private var podcast: Podcast!
    
    var moreThanThreeLines: Bool {
        return podcastDescription.maxNumberOfLines > 3
    }
    
    //MARK: Public Methods
    func configureCell(_ delegate: PodcastCellDelegate?, with podcast: Podcast) {
        self.delegate = delegate
        configure(with: podcast)
    }

    //MARK: Actions
    @objc func handlerTapFavoriteStar(_ sender: UITapGestureRecognizer) {
        
        if !podcast.isFavorite {
            let imageArray = self.createImageArray(total: 5, imagePrafix: "star")
            favoriteStarImageView.animationImages = imageArray
            favoriteStarImageView.animationDuration = 1.0
            favoriteStarImageView.animationRepeatCount = 1
            favoriteStarImageView.startAnimating()
            favoriteStarImageView.image = UIImage(named: "star5")
            Timer.scheduledTimer(withTimeInterval: 0.9, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.podcastCellDidSelectStar(self)
                self.setDownloadImage(self.podcast)
            }
        } else {
            favoriteStarImageView.image = UIImage(named: "star1")
            delegate?.podcastCellDidSelectStar(self)
            setDownloadImage(podcast)
        }
    }
    
    @objc func tapPlayPauseButton(_ sender: UITapGestureRecognizer) {
        if playStopButton.image == pauseImage {
            delegate?.podcastCellDidTouchStopButton(self)
        } else {
            delegate?.podcastCellDidTouchPlayButton(self)
        }
    }
    
    @objc func handlerTapDownloadImage(_ sender: UITapGestureRecognizer) {
        
        switch podcast.stateOfDownload {
        case .notDownloaded:
            startDownloading()
        default: break
        }
        
        delegate?.podcastCellDidSelectDownLoadImage(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//MARK: - Player update methods
extension PodcastCell {
    
    func updatePlayStopButton(player: PodcastCellPlayableProtocol) {
        playStopButton.image = player.isPlaying ? pauseImage : playImage
    }
    
    func playerIsGoingPlay(player: PodcastCellPlayableProtocol) {
        if listeningProgressView.progress == 0 {
            listeningProgressView.isHidden = false
            listeningProgressView.progress = 1
        }
        
        playerActivityIndicator.isHidden = false
        playerActivityIndicator.startAnimating()
        playStopButton.isHidden = true
    }
    
    func playerIsEndLoading(player: PodcastCellPlayableProtocol) {
        playerActivityIndicator.stopAnimating()
        playStopButton.isHidden = false
        playStopButton.image = pauseImage
    }
    
    func updateListeningProgressView(player: PodcastCellPlayableProtocol) {
        updatePlayStopButton(player: player)
        setListeningProgressView(progress: player.progress)
    }
}

//MARK: - Download updating
extension PodcastCell {
    
    func updateDownloadInformation(progress: Float, totalSize : String) {
        
        if !downloadActivityIndicator.isHidden { downloadActivityIndicator.stopAnimating() }
        if downLoadImageView.isHidden { downLoadImageView.isHidden = false }
        if downloadProgressView.isHidden { downloadProgressView.isHidden = false }
        if downloadProgressLabel.isHidden { downloadProgressLabel.isHidden = false }
        
        downloadProgressView.progress = progress
        downloadProgressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
    }
    
    func endDownloading() {
        downloadProgressView.isHidden = true
        downloadProgressLabel.isHidden = true
        downLoadImageView.image = UIImage(systemName: "checkmark.icloud.fill")
    }
    
    func startDownloading() {
        downloadActivityIndicator.isHidden = false
        downloadActivityIndicator.startAnimating()
        downLoadImageView.isHidden = true
    }
        
    func removePodcastFromDownloads() {
        downloadActivityIndicator.stopAnimating()
        downloadProgressView.isHidden = true
        downloadProgressLabel.isHidden = true
        downLoadImageView.image = UIImage(systemName: "icloud.and.arrow.down")
    }

}

//MARK: - Private Methods
extension PodcastCell {

    private func setListeningProgressView(progress: Double?) {
        listeningProgressView.progress = Float(progress ?? 0)
        listeningProgressView.isHidden = (listeningProgressView.progress == 0)
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
    
    private func setDownloadImage(_ podcast: Podcast) {
        let trackIsAvailableForPlaying = (podcast.episodeUrl != nil)
        if trackIsAvailableForPlaying {
            downLoadImageView.isHidden = !podcast.isFavorite
            downLoadImageView.image = UIImage(systemName: podcast.stateOfDownload == .isDownload ? "checkmark.icloud.fill" : "icloud.and.arrow.down")
        } else {
            downLoadImageView.isHidden = true
            playStopButton.isHidden = true
        }
    }
    
    private func setFavoriteStarImage(podcast: Podcast) {
        favoriteStarImageView.image = UIImage(named: podcast.isFavorite ? "star5" : "star1")
    }
    
    private func configure(with podcast: Podcast) {
        self.podcast = podcast
        configureGestures()
        dateLabel.text = podcast.formattedDate(dateFormat: "d MMM YYY")
        trackDuration.text = podcast.trackTimeMillis?.minute
        podcastDescription.text = podcast.descriptionMy
        
        podcastDescription.numberOfLines = podcastDescription.maxNumberOfLines
        openDescriptionImageView.isHidden = !moreThanThreeLines
        openDescriptionImageView.image = isSelected ? downImage : upImage

        podcastName.text = podcast.trackName
        setListeningProgressView(progress: podcast.progress)
        setFavoriteStarImage(podcast: podcast)
        setDownloadImage(podcast)
        
        DataProvider.shared.downloadImage(string: podcast.image160) { [weak self] image in
            self?.podcastImage.image = image
        }
    }
    
    private func configureGestures() {
        downLoadImageView.addMyGestureRecognizer(self, type: .tap(), #selector(handlerTapDownloadImage))
        playStopButton.addMyGestureRecognizer(self, type: .tap(), #selector(tapPlayPauseButton))
        favoriteStarImageView.addMyGestureRecognizer(self, type: .tap(), #selector(handlerTapFavoriteStar))
    }
}
