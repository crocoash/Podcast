//
//  PodcastCell.swift
//  Podcasts
//
//  Created by student on 26.10.2021.
//

import UIKit

//MARK: - Delegate
protocol PodcastCellDelegate: AnyObject {
    func podcastCellDidSelectStar         (_ podcastCell: PodcastCell)
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell)
    func podcastCellDidTouchPlayButton    (_ podcastCell: PodcastCell)
    func podcastCellDidTouchStopButton    (_ podcastCell: PodcastCell)
}

//MARK: - PlayableProtocol
protocol PodcastCellPlayableProtocol {
    var isPlaying: Bool { get }
    var isGoingPlaying: Bool { get }
    var listeningProgress: Double? { get }
    var duration: Double? { get }
    var trackId: String { get }
}

protocol PodcastCellDownloadProtocol {
    var downloadId: String { get }
    var isDownloading: Bool { get }
    var isDownloaded: Bool { get }
    var isGoingDownload: Bool { get }
    var downloadingProgress: Float  { get }
    var downloadTotalSize : String  { get }
}

protocol PodcastCellFavoriteProtocol {
    var isFavorite: Bool { get }
}

protocol InputPodcastCell {
    var inputPodcastCell: PodcastCellProtocol { get }
}

protocol PodcastCellProtocol {
    var id: String { get }
    var trackDuration: String? { get }
    var dateDuration: String { get }
    var descriptionMy: String? { get }
    var trackName: String? { get }
    var imageForPodcastCell: String? { get }
    var listeningProgress: Double? { get }
}

protocol UpdatingTypes: PodcastCellDownloadProtocol, PodcastCellPlayableProtocol & PodcastCellFavoriteProtocol {}

struct PodcastCellModel: PodcastCellProtocol, UpdatingTypes {
    
    var id: String
    var isFavorite: Bool
    var trackDuration: String?
    var dateDuration: String
    var descriptionMy: String?
    var trackName: String?
    var imageForPodcastCell: String?
    var listeningProgress: Double?
    
    ///DownloadServiceInformation
    var downloadId: String
    var downloadingProgress: Float = 0

    var isDownloading: Bool
    var isGoingDownload: Bool
    var downloadTotalSize : String = ""
    var isDownloaded: Bool
    
    ///Player
    var isPlaying: Bool = false
    var isGoingPlaying: Bool = false
    
    var duration: Double?
    var trackId: String
    
    init(_ inputPodcastCell: any InputPodcastCell, isFavorite: Bool, isDownloaded: Bool) {
        
        let inputType = inputPodcastCell.inputPodcastCell
        
        self.id = inputType.id
        self.trackDuration = inputType.trackDuration
        self.dateDuration = inputType.dateDuration
        self.descriptionMy = inputType.descriptionMy
        self.trackName = inputType.trackName
        self.imageForPodcastCell = inputType.imageForPodcastCell
        self.trackId = inputType.id
        self.downloadId = inputType.id
        self.listeningProgress = inputType.listeningProgress
        
        self.isFavorite =  isFavorite  //inputType.isFavorite
        self.isDownloaded = isDownloaded ///
        
        self.isDownloading = false
        self.isGoingDownload = false
    }
    
    mutating func updateModel(_ input: Any) {
        
        if let player = input as? PodcastCellPlayableProtocol {
            
            if player.trackId == trackId {
                self.isPlaying = player.isPlaying
                self.isGoingPlaying = player.isGoingPlaying
                self.listeningProgress = player.listeningProgress
                self.duration = player.duration
            }
        }
        
        if let download = input as? PodcastCellDownloadProtocol {
            
            if download.downloadId == downloadId {
                self.isDownloaded = download.isDownloaded
                self.isDownloading  = download.isDownloading
                self.isGoingDownload = download.isGoingDownload
                self.downloadingProgress = download.downloadingProgress
                self.downloadTotalSize = download.downloadTotalSize
            }
        }
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
    
    private(set) var model: PodcastCellModel! {
        didSet {
            updateCell()
        }
    }
    
    weak var delegate: PodcastCellDelegate?
    
    var moreThanThreeLines: Bool {
        return podcastDescription.maxNumberOfLines > 3
    }
    
    private var defaultHeight: CGFloat = 50
    
    override var isSelected: Bool {
        didSet {
            updateSelectState()
        }
    }
    
    func configureCell(_ delegate: PodcastCellDelegate?, with inputPodcastCell: InputPodcastCell,  isFavorite: Bool, isDownloaded: Bool) {
        self.delegate = delegate
        self.model = PodcastCellModel(inputPodcastCell, isFavorite: isFavorite, isDownloaded: isDownloaded)
        self.heightOfImageView.constant = (frame.height - dateLabel.frame.height) - 10
        
        configureGestures()
        updateCell()
        
        //TODO: 
        DataProvider.shared.downloadImage(string: model.imageForPodcastCell) { [weak self] image in
            self?.podcastImage.image = image
        }
    }
    
    func update(with input: Any) {
        if let input = input as? PodcastCellModel {
            self.model = input
        } else {
            model.updateModel(input)
        }
    }
    
    func updateCell() {
        dateLabel.text = model.dateDuration
        trackDuration.text = model.trackDuration
        podcastDescription.text = model.descriptionMy
        podcastName.text = model.trackName
        
        updateOpenDescriptionInfo()
        updateSelectState()
        updatePlayerUI()
        updateFavoriteStar()
        updateDownloadUI()
    }

    
    //MARK: Actions
    @objc func handlerTapFavoriteStar(_ sender: UITapGestureRecognizer) {
        delegate?.podcastCellDidSelectStar(self)
    }
    
    @objc func tapPlayPauseButton(_ sender: UITapGestureRecognizer) {
        delegate?.podcastCellDidTouchPlayButton(self)
    }
    
    @objc func handlerTapDownloadImage(_ sender: UITapGestureRecognizer) {
        delegate?.podcastCellDidSelectDownLoadImage(self)
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
    
    func updateFavoriteStar() {
        favoriteStarImageView.image = model.isFavorite ? isFavoriteImage : isNotFavoriteImage
        updateDownloadUI()
    }
    
    func updateFavoriteStar(with value: Bool) {
        self.model.isFavorite = value
        updateFavoriteStar()
    }
    
    func updatePlayerUI() {
        playStopButton.image = model.isPlaying ? pauseImage : playImage
        playStopButton.isHidden = model.isGoingPlaying
        
        listeningProgressView.progress = Float(model.listeningProgress ?? 0)
        listeningProgressView.isHidden = model.listeningProgress == 0
        
        if model.isGoingPlaying {
            playerActivityIndicator.startAnimating()
        } else {
            playerActivityIndicator.stopAnimating()
        }
        
        playerActivityIndicator.isHidden = !model.isGoingPlaying
    }
    
    func updateDownloadUI() {
        
        let isFavorite = model.isFavorite
        
        let isDownloaded = model.isDownloaded
        let isGoingDownload = model.isGoingDownload
        let isDownloading  = model.isDownloading
        
        if isFavorite {
            downloadProgressView.isHidden = !model.isDownloading  ///+++
            downloadActivityIndicator.isHidden = !model.isGoingDownload ///+++
            downLoadImageView.isHidden = isGoingDownload
            downloadProgressLabel.isHidden = !isDownloading
            
            downloadProgressView.progress = model.downloadingProgress
            downloadProgressLabel.text = String(format: "%.1f%% of %@", model.downloadingProgress * 100, model.downloadTotalSize)
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

    private func updateOpenDescriptionInfo() {
        podcastDescription.numberOfLines = podcastDescription.maxNumberOfLines
        openDescriptionImageView.isHidden = !moreThanThreeLines
    }
    
    private func configureGestures() {
        downLoadImageView.addMyGestureRecognizer(self, type: .tap(), #selector(handlerTapDownloadImage))
        playStopButton.addMyGestureRecognizer(self, type: .tap(), #selector(tapPlayPauseButton))
        favoriteStarImageView.addMyGestureRecognizer(self, type: .tap(), #selector(handlerTapFavoriteStar))
    }
}
