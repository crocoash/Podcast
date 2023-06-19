//
//  PodcastCell.swift
//  Podcasts
//
//  Created by student on 26.10.2021.
//

import UIKit

//MARK: - Delegate
protocol PodcastCellDelegate: AnyObject {
    func podcastCellDidSelectStar         (_ podcastCell: PodcastCell, entity: PodcastCellType)
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell, entity: PodcastCellType)
    func podcastCellDidTouchPlayButton    (_ podcastCell: PodcastCell, entity: PodcastCellType)
    func podcastCellDidTouchStopButton    (_ podcastCell: PodcastCell, entity: PodcastCellType)
}

//MARK: - PlayableProtocol
protocol PodcastCellPlayableProtocol {
    var isPlaying: Bool { get }
    var isGoingPlaying: Bool { get }
    var listeningProgress: Double? { get }
}

struct PodcastCellType: DownloadProtocol {
    var identifier: String
    var isFavorite: Bool
    var trackDuration: String?
    var dateDuration: String
    var descriptionMy: String?
    var trackName: String?
    var downloadUrl: String?
    var image: String?
    
    ///DownloadServiceInformation
    var isDownloading: Bool = false
    var isGoingDownload: Bool = false
    var downloadingProgress: Float = 0
    var downloadTotalSize : String = ""

    ///Player
    var player: PodcastCellPlayableProtocol?
    
    init(podcast: Podcast) {
        self.identifier = podcast.identifier
        self.isFavorite = podcast.isFavorite
        self.trackDuration = podcast.trackTimeMillis?.minute
        self.dateDuration = podcast.formattedDate(dateFormat: "d MMM YYY")
        self.descriptionMy = podcast.descriptionMy
        self.trackName = podcast.trackName
        self.downloadUrl = podcast.downloadUrl
        self.image = podcast.image160
    }
    
    init(favoritePodcast: FavoritePodcast) {
        self.init(podcast: favoritePodcast.podcast)
    }
    
    mutating func updateDownloadingInformation(_ downloadServiceType: DownloadServiceType) {
        self.isDownloading  = downloadServiceType.isDownloading
        self.isGoingDownload = downloadServiceType.isGoingDownload
        self.downloadingProgress = downloadServiceType.downloadingProgress
        self.downloadTotalSize = downloadServiceType.downloadTotalSize
    }
    
    mutating func updatePlayableInformation(_ podcastCellPlayableProtocol: PodcastCellPlayableProtocol) {
        self.player = podcastCellPlayableProtocol
    }
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

    @IBOutlet private weak var heightOfImageView: NSLayoutConstraint!
    
    private let pauseImage = UIImage(systemName: "pause.circle.fill")!
    private let playImage = UIImage(systemName: "play.circle.fill")!
    private let downImage = UIImage(systemName: "chevron.down")!
    private let upImage = UIImage(systemName: "chevron.up")!
    
    private let isFavoriteImage = UIImage(named: "star5")!
    private let isNotFavoriteImage = UIImage(named: "star1")!
    
    
    weak var delegate: PodcastCellDelegate?
    private var podcast: PodcastCellType!
    
    var moreThanThreeLines: Bool {
        return podcastDescription.maxNumberOfLines > 3
    }
    
    override var isSelected: Bool {
        didSet {
           updateSelectState()
        }
    }
    
    //MARK: Public Methods
    func configureCell(_ delegate: PodcastCellDelegate?, with podcast: PodcastCellType) {
        self.delegate = delegate
        configure(with: podcast)
    }

    //MARK: Actions
    @objc func handlerTapFavoriteStar(_ sender: UITapGestureRecognizer) {
        delegate?.podcastCellDidSelectStar(self, entity: podcast)
    }
    
    @objc func tapPlayPauseButton(_ sender: UITapGestureRecognizer) {
        delegate?.podcastCellDidTouchPlayButton(self, entity: podcast)
    }
    
    @objc func handlerTapDownloadImage(_ sender: UITapGestureRecognizer) {
        delegate?.podcastCellDidSelectDownLoadImage(self, entity: podcast)
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
    
    
    
    func configure(with podcast: PodcastCellType) {
        self.podcast = podcast
        
        heightOfImageView.constant = bounds.height * 0.8
        configureGestures()
        dateLabel.text = podcast.dateDuration
        trackDuration.text = podcast.trackDuration
        podcastDescription.text = podcast.descriptionMy
        
        podcastDescription.numberOfLines = podcastDescription.maxNumberOfLines
        openDescriptionImageView.isHidden = !moreThanThreeLines
        
        
        podcastName.text = podcast.trackName
        
        DataProvider.shared.downloadImage(string: podcast.image) { [weak self] image in
            self?.podcastImage.image = image
        }
     
        updateSelectState()
        updatePlayerUI()
        updateFavoriteStar()
        updateDownloadUI()
    }
    
    func updateSelectState() {
        openDescriptionImageView.image = isSelected ? downImage : upImage
    }
    
    func updateFavoriteStar() {
        favoriteStarImageView.image = podcast.isFavorite ? isFavoriteImage : isNotFavoriteImage
        updateDownloadUI()
    }
    
    func updateFavoriteStar(with value: Bool) {
        self.podcast.isFavorite = value
        updateFavoriteStar()
    }
    
    func updatePlayerInformation(with podcastCellPlayableProtocol: PodcastCellPlayableProtocol) {
        self.podcast.player = podcastCellPlayableProtocol
        updatePlayerUI()
    }
    
    func updatePlayerUI() {
        guard let player = podcast.player else { return }
        playStopButton.image = player.isPlaying ? pauseImage : playImage
        playStopButton.isHidden = player.isGoingPlaying
        
        listeningProgressView.progress = Float(player.listeningProgress ?? 0)
        listeningProgressView.isHidden = player.listeningProgress == 0
        
        if player.isGoingPlaying {
            playerActivityIndicator.startAnimating()
        } else {
            playerActivityIndicator.stopAnimating()
        }
        
        playerActivityIndicator.isHidden = !player.isGoingPlaying
    }
    
    func updateDownloadInformation(with downloadServiceType: DownloadServiceType) {
        self.podcast.updateDownloadingInformation(downloadServiceType)
        updateDownloadUI()
    }
    
    func updateDownloadUI() {
        
        let isFavorite = podcast.isFavorite
        
        let isDownloaded = podcast.isDownloaded
        let isGoingDownload = podcast.isGoingDownload
        let isDownloading  = podcast.isDownloading
        
        if isFavorite {
            downloadProgressView.isHidden = !podcast.isDownloading  ///+++
            downloadActivityIndicator.isHidden = !podcast.isGoingDownload ///+++
            downLoadImageView.isHidden = isGoingDownload
            downloadProgressLabel.isHidden = !isDownloading
            
            downloadProgressView.progress = podcast.downloadingProgress
            downloadProgressLabel.text = String(format: "%.1f%% of %@", podcast.downloadingProgress * 100, podcast.downloadTotalSize)
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
    
    
    private func configureGestures() {
        downLoadImageView.addMyGestureRecognizer(self, type: .tap(), #selector(handlerTapDownloadImage))
        playStopButton.addMyGestureRecognizer(self, type: .tap(), #selector(tapPlayPauseButton))
        favoriteStarImageView.addMyGestureRecognizer(self, type: .tap(), #selector(handlerTapFavoriteStar))
    }
}
