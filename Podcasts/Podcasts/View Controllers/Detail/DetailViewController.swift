//
//  DetailViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit

protocol DetailViewControllerDelegate: AnyObject {
    func detailViewControllerPlayButtonDidTouchFor(_ detailViewController: DetailViewController, podcast: Podcast, at moment: Double?, playlist: [Podcast])
    func detailViewControllerPlayStopButtonDidTouchInSmallPlayer(_ detailViewController: DetailViewController)
    func detailViewControllerDidSwipeOnPlayer(_ detailViewController: DetailViewController)
    func detailViewControllerStopButtonDidTouchFor(_ detailViewController: DetailViewController, podcast: Podcast)
    func detailViewController(_ detailViewController: DetailViewController, addToFavoriteButtonDidTouchFor podcast: Podcast)
    func detailViewController(_ detailViewController: DetailViewController, removeFromFavoriteButtonDidTouchFor selectedPodcast: Podcast)
    func detailViewControllerDidSelectDownLoadImage(_ detailViewController: DetailViewController, entity: DownloadServiceProtocol, completion: @escaping () -> Void)
}

protocol DetailPlayable {
    
}

class DetailViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var episodeName        : UILabel!
    @IBOutlet private weak var artistName         : UILabel!
    @IBOutlet private weak var countryLabel       : UILabel!
    @IBOutlet private weak var durationLabel      : UILabel!
    @IBOutlet private weak var advisoryRatingLabel: UILabel!
    @IBOutlet private weak var dateLabel          : UILabel!
    @IBOutlet private weak var genresLabel        : UILabel!
    
    @IBOutlet private(set) weak var smallPlayerView: SmallPlayerView!
    
    @IBOutlet private weak var descriptionTextView: UITextView!
    
    @IBOutlet private weak var episodeImage              : UIImageView!
    @IBOutlet private weak var backImageView             : UIImageView!
    @IBOutlet private weak var removeFromPlaylistBookmark: UIImageView!
    @IBOutlet private weak var addToPlaylistBookmark     : UIImageView!
    @IBOutlet private weak var playImageView             : UIImageView!
    
    @IBOutlet private weak var episodeTableView: EpisodeTableView!
    @IBOutlet private weak var heightTableViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomPlayerConstraint:NSLayoutConstraint!
    
//    cell.setHighlighted(true, animated: true)
    
    //MARK: Variables
    private(set) var podcast: Podcast!
    private(set) var podcasts: [Podcast]! {
        didSet {
            if let _ = oldValue {
                setupView()
            }
        }
    }

    weak var delegate: DetailViewControllerDelegate?
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGestures()
        setupView()
    }

    
    //MARK: Public Methods
    func setUp(podcast: Podcast, playlist: [Podcast]) {
        self.podcast = podcast
        self.podcasts = playlist
    }
    
    func updateConstraintForTableView(playerIsPresent: Bool) {
        smallPlayerView.isHidden = !playerIsPresent
        bottomPlayerConstraint.constant = playerIsPresent ? 50 : 0
        view.layoutIfNeeded()
    }
    
    func setupView() {
        episodeImage.image = nil
        DataProvider.shared.downloadImage(string: podcast?.image600) { [weak self] image in
            self?.episodeImage.image = image
        }
        smallPlayerView.delegate = self
        episodeTableView.translatesAutoresizingMaskIntoConstraints = false
        episodeTableView.configureEpisodeTableView(self, with: podcasts)
    
        episodeName        .text = podcast?.trackName
        artistName         .text = podcast.artistName ?? "Artist Name"
        genresLabel        .text = podcast?.genresString
        descriptionTextView.text = podcast?.description
        countryLabel       .text = podcast?.country
        advisoryRatingLabel.text = podcast?.contentAdvisoryRating
        dateLabel          .text = podcast?.releaseDateInformation.formattedDate(dateFormat: "d MMM YYY")
        durationLabel      .text = podcast?.trackTimeMillis?.minute
    }
    
    ///BigPlayer
    func scrollToCell(id: NSNumber?) {
        let positionOfCell = episodeTableView.positionYOfCell(id: id)
        let positionOfTableView = episodeTableView.frame.origin.y
        let position = positionOfTableView + positionOfCell
        scrollView.setContentOffset(CGPoint(x: .zero, y: position), animated: true)
    }
    
    //MARK: Downloading
    func updateDownloadInformation(progress: Float, totalSize: String, for podcast: Podcast) {
        episodeTableView.updateDownloadInformation(progress: progress, totalSize: totalSize, for: podcast)
    }
    
    func endDownloading(podcast: Podcast) {
        episodeTableView.endDownloading(podcast: podcast)
    }
    
    //MARK: - Actions
    @IBAction private func backAction(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
        view.endEditing(true)
    }
    
    @IBAction private func refreshByGenre(_ sender: UICommand) {
        episodeTableView.changeTypeOfSort(.byGenre)
    }
    
    @IBAction private func refreshByNewest(_ sender: UICommand) {
        episodeTableView.changeTypeOfSort(.byNewest)
    }
    
    @IBAction private func refreshByOldest(_ sender: UICommand) {
        episodeTableView.changeTypeOfSort(.byOldest)
    }
    
    @IBAction private func shareButtonOnTouch(_ sender: UITapGestureRecognizer) {
        presentActivityViewController()
    }
}

//MARK: - Private Methods
extension DetailViewController {
    
    private func configureGestures() {
        addMyGestureRecognizer(self, type: .screenEdgePanGestureRecognizer(directions: [.left]), #selector(backAction))
    }
    
    private func reloadTableViewHeightConstraint(newHeight: CGFloat) {
            heightTableViewConstraint.constant = newHeight
            view.layoutIfNeeded()
    }
    
    private func presentActivityViewController() {
        guard let trackViewUrl = podcast.trackViewUrl,
              let image = episodeImage.image else { return }
        let text = "You should definitely listen to this!"
        
        let shareVC = UIActivityViewController(activityItems: [text, trackViewUrl, image], applicationActivities: [])
    
        if let popoverController = shareVC.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = view.bounds
        }
        present(shareVC, animated: true)
    }
}

//MARK: - EpisodeTableViewControllerMyDataSource
extension DetailViewController: EpisodeTableViewMyDataSource {
    
    func episodeTableViewDidChangeHeightTableView(_ episodeTableView: EpisodeTableView, height: CGFloat, withLastCell: Bool) {
        if withLastCell {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.reloadTableViewHeightConstraint(newHeight: height)
                guard let self = self, let view = self.view else { return }
                
                let heightOfSmallPlayer = self.smallPlayerView.isHidden ? 0 : self.smallPlayerView.frame.height
                let y = episodeTableView.frame.maxY - (view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom) + heightOfSmallPlayer
                self.scrollView.setContentOffset(CGPoint(x: .zero, y: y), animated: true)
            }
        } else {
            UIView.animate(withDuration: 0.4) { [weak self] in
                self?.reloadTableViewHeightConstraint(newHeight: height)
            }
        }
    }
}

//MARK: - EpisodeTableViewControllerDelegate
extension DetailViewController: EpisodeTableViewDelegate {
    
    func episodeTableViewPlayButtonDidTouchFor(_ episodeTableView: EpisodeTableView, podcast: Podcast, at moment: Double?, playlist: [Podcast]) {
        delegate?.detailViewControllerPlayButtonDidTouchFor(self, podcast: podcast, at: moment, playlist: playlist)
    }
    
    func episodeTableViewStopButtonDidTouchFor(_ episodeTableView: EpisodeTableView) {
        delegate?.detailViewControllerPlayStopButtonDidTouchInSmallPlayer(self)
    }
    
    func episodeTableView(_ episodeTableView: EpisodeTableView, addToFavoriteButtonDidTouchFor podcast: Podcast) {
        delegate?.detailViewController(self, addToFavoriteButtonDidTouchFor: podcast)
        addToast(title: podcast.isFavorite ? "added" : "removed", smallPlayerView.isHidden ? .bottom : .bottomWithPlayer)
    }
    
    func episodeTableView(_ episodeTableView: EpisodeTableView, removeFromFavoriteButtonDidTouchFor selectedPodcast: Podcast) {
        delegate?.detailViewController(self, removeFromFavoriteButtonDidTouchFor: selectedPodcast)
    }
    
    func episodeTableViewDidSelectDownLoadImage(_ episodeTableView: EpisodeTableView, entity: DownloadServiceProtocol, completion: @escaping () -> Void) {
        delegate?.detailViewControllerDidSelectDownLoadImage(self, entity: entity, completion: completion)
    }
}

//MARK: - SmallPlayerViewControllerDelegate
extension DetailViewController: SmallPlayerViewControllerDelegate {
    
    func smallPlayerViewControllerSwipeOrTouch(_ smallPlayerViewController: SmallPlayerView) {
        delegate?.detailViewControllerDidSwipeOnPlayer(self)
    }
    
    func smallPlayerViewControllerDidTouchPlayStopButton(_ smallPlayerViewController: SmallPlayerView) {
        delegate?.detailViewControllerPlayStopButtonDidTouchInSmallPlayer(self)
    }
}