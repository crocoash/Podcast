//
//  DetailViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit
import CoreData

protocol DetailViewControllerDelegate: AnyObject {
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

    //MARK: Variables
    private(set) var podcast: Podcast
    private(set) var podcasts: [Podcast]
    
    private var player: InputPlayer
    private var downloadService: DownloadServiceInput
    private var bigPlayerViewController: BigPlayerViewController?
    private var likeManager: InputLikeManager
    private var favoritePodcast: FavoriteManager
    
    weak var delegate: DetailViewControllerDelegate?
    
    enum TypeSortOfTableView {
        case byNewest
        case byOldest
        case byGenre
    }
    
    lazy private var typeOfSort: TypeSortOfTableView = .byGenre

    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGestures()
        setupView()
        addObserverPlayerEventNotification()
        addDownloadEventNotifications()
        let height = getHeightOfTableView()
        reloadTableViewHeightConstraint(newHeight: height)
    }
    
    //MARK: Public Methods
    init?<T: DetailViewControllerDelegate & UIViewControllerTransitioningDelegate>(
        coder: NSCoder,
        _ vc : T,
        podcast: Podcast,
        playlist: [Podcast],
        player: InputPlayer,
        downloadService: DownloadServiceInput,
        likeManager: InputLikeManager,
        addToFavoritePodcast: FavoriteManager
    ) {
      
        self.podcast = podcast
        self.podcasts = playlist
        self.delegate = vc
        self.player = player
        self.downloadService = downloadService
        self.likeManager = likeManager
        self.favoritePodcast = addToFavoritePodcast
        
        super.init(coder: coder)
        
        modalPresentationStyle = .custom
        self.transitioningDelegate = vc
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Public Methods
    func scrollToCell(podcast: Podcast) {
        guard let index = podcasts.firstIndex(matching: podcast) else { fatalError() }
        let positionOfCell = episodeTableView.getYPositionYFor(indexPath: IndexPath(row: index, section: 1))
        let positionOfTableView = episodeTableView.frame.origin.y
        let position = positionOfTableView + positionOfCell
        scrollView.setContentOffset(CGPoint(x: .zero, y: position), animated: true)
    }
    
    //MARK: - Actions
    @IBAction private func backAction(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
        view.endEditing(true)
    }
    
    @IBAction private func refreshByGenre(_ sender: UICommand) {
        episodeTableView.reloadData()
    }
    
    @IBAction private func refreshByNewest(_ sender: UICommand) {
        episodeTableView.reloadData()
    }
    
    @IBAction private func refreshByOldest(_ sender: UICommand) {
        episodeTableView.reloadData()
    }
    
    @IBAction private func shareButtonOnTouch(_ sender: UITapGestureRecognizer) {
        presentActivityViewController()
    }
    
    //MARK: Actions
    @objc func tapCell(sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? PodcastCell,
              cell.moreThanThreeLines
        else { return }
        
        cell.isSelected = !cell.isSelected
        episodeTableView.openCell(cell)
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
    
    private func presentSmallPlayer(with inputType: SmallPlayerPlayableProtocol) {
        
        if smallPlayerView.isHidden {
                let model = SmallPlayerViewModel(inputType)
                self.smallPlayerView.configure(with: model, player: player)
                smallPlayerView.isHidden = false
                bottomPlayerConstraint.constant = 50
                view.layoutIfNeeded()
        }
    }
    
    private func presentBigPlayer(with track: BigPlayerPlayableProtocol) {
        let bigPlayerViewController = BigPlayerViewController(self, player: player, track: track, likeManager: likeManager)
        self.bigPlayerViewController = bigPlayerViewController
        bigPlayerViewController.modalPresentationStyle = .fullScreen
        self.present(bigPlayerViewController, animated: true)
    }
    
    private func setupView() {
        episodeImage.image = nil
        DataProvider.shared.downloadImage(string: podcast.image600) { [weak self] image in
            self?.episodeImage.image = image
        }
        smallPlayerView.delegate = self
        episodeTableView.translatesAutoresizingMaskIntoConstraints = false
        episodeTableView.configureEpisodeTableView(self)
        
        episodeName        .text = podcast.trackName
        artistName         .text = podcast.artistName ?? "Artist Name"
        genresLabel        .text = podcast.genresString
        descriptionTextView.text = podcast.description
        countryLabel       .text = podcast.country
        advisoryRatingLabel.text = podcast.contentAdvisoryRating
        dateLabel          .text = podcast.releaseDateInformation.formattedDate(dateFormat: "d MMM YYY")
        durationLabel      .text = podcast.trackTimeMillis?.minute
    }
    
    private func getPodcast(for indexPath: IndexPath) -> Podcast {
        return podcasts[indexPath.row]
    }
    
    private func getHeightOfTableView() -> CGFloat {
        podcasts.count * episodeTableView.defaultRowHeight
    }
}

//MARK: - EpisodeTableViewControllerMyDataSource
extension DetailViewController: EpisodeTableViewMyDataSource {
//
    func episodeTableViewDidChangeHeightTableView(_ episodeTableView: EpisodeTableView, height: CGFloat, with lastCell: Bool) {
        if lastCell {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.reloadTableViewHeightConstraint(newHeight: height)
                guard let self = self, let view = view else { return }

                let heightOfSmallPlayer = smallPlayerView.isHidden ? 0 : smallPlayerView.frame.height
                let y = episodeTableView.frame.maxY - (view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom) + heightOfSmallPlayer
                scrollView.setContentOffset(CGPoint(x: .zero, y: y), animated: true)
            }
        } else {
            UIView.animate(withDuration: 0.4) { [weak self] in
                guard let self = self else { return }
                reloadTableViewHeightConstraint(newHeight: height)
            }
        }
    }
}

//MARK: - UITableViewDataSource
extension DetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return headers[section]
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
        let podcast = getPodcast(for: indexPath)

//        cell.isSelected = episodeTableView.selectedCellAndHisHeight[indexPath] != nil
        cell.addMyGestureRecognizer(self, type: .tap(), #selector(tapCell))
        
        let isFavorite = favoritePodcast.isFavorite(podcast)
        let isDownloaded = downloadService.isDownloaded(entity: podcast)
        cell.configureCell(self, with: podcast, isFavorite: isFavorite, isDownloaded: isDownloaded)
        
        return cell
    }
}


//MARK: - SmallPlayerViewControllerDelegate
extension DetailViewController: SmallPlayerViewControllerDelegate {
    
    func smallPlayerViewControllerSwipeOrTouch(_ smallPlayerViewController: SmallPlayerView) {
        guard let track = player.currentTrack?.track else { return }
        presentBigPlayer(with: track)
    }
}

//MARK: - DownloadServiceDelegate
extension DetailViewController: DownloadEventNotifications {
    
    func addDownloadEventNotifications() {
        downloadService.addObserverDownloadEventNotifications(for: self)
    }
    
    func updateDownloadInformation(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        episodeTableView.update(with: entity)
    }
    
    func didEndDownloading(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        episodeTableView.update(with: entity)
    }
    
    func didPauseDownload(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        episodeTableView.update(with: entity)
    }
    
    func didContinueDownload(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        episodeTableView.update(with: entity)
    }
    
    func didStartDownload(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        episodeTableView.update(with: entity)
    }
    
    func didRemoveEntity(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        episodeTableView.update(with: entity)
    }
}

//MARK: - BigPlayerViewControllerDelegate
extension DetailViewController: BigPlayerViewControllerDelegate {
    
    func bigPlayerViewControllerDidTouchPodcastNameLabel(_ bigPlayerViewController: BigPlayerViewController, entity: NSManagedObject) {
        bigPlayerViewController.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            
        })
    }
}

//MARK: - PlayerEventNotification
extension DetailViewController: PlayerEventNotification {
    
    func addObserverPlayerEventNotification() {
        player.addObserverPlayerEventNotification(for: self)
    }
    
    func playerDidEndPlay(with track: OutputPlayerProtocol) {
        episodeTableView.update(with: track)
    }
    
    func playerStartLoading(with track: OutputPlayerProtocol) {
        presentSmallPlayer(with: track)
        episodeTableView.update(with: track)
    }
    
    func playerDidEndLoading(with track: OutputPlayerProtocol) {
        episodeTableView.update(with: track)
    }
    
    func playerUpdatePlayingInformation(with track: OutputPlayerProtocol) {
        presentSmallPlayer(with: track)
        episodeTableView.update(with: track)
    }
    
    func playerStateDidChanged(with track: OutputPlayerProtocol) {
        episodeTableView.update(with: track)
    }
}


//MARK: - PodcastCellDelegate
extension DetailViewController: PodcastCellDelegate {

    func podcastCellDidSelectStar(_ podcastCell: PodcastCell) {
        guard let indexPath = episodeTableView.indexPath(for: podcastCell) else { return }
        let podcast = getPodcast(for: indexPath)
        favoritePodcast.addOrRemoveFavoritePodcast(entity: podcast)
        episodeTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell) {
        guard let indexPath = episodeTableView.indexPath(for: podcastCell) else { return }
        let podcast = getPodcast(for: indexPath)
        downloadService.conform(entity: podcast)
    }
    
    func podcastCellDidTouchPlayButton(_ podcastCell: PodcastCell) {
        guard let indexPath = episodeTableView.indexPath(for: podcastCell) else { return }
        let podcast = getPodcast(for: indexPath)
        player.conform(entity: podcast, entities: podcasts)
    }
    
    func podcastCellDidTouchStopButton(_ podcastCell: PodcastCell) {
        player.playOrPause()
    }
}

//MARK: - UITableViewDelegate
extension DetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let cell = tableView.cellForRow(at: indexPath), cell.isSelected {
            if let cell = cell as? PodcastCell, cell.moreThanThreeLines {
                return UITableView.automaticDimension
            }
        }
        
        return episodeTableView.defaultRowHeight
    }
}
