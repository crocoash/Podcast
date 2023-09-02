//
//  DetailViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit
import CoreData

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
   
   private var player: PlayerInput
   private var downloadService: DownloadServiceInput
   private var bigPlayerViewController: BigPlayerViewController?
   private var likeManager: LikeManagerInput
   private var favouriteManager: FavouriteManagerInput
   
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
      downloadService.delegate = self
      favouriteManager.delegate = self
      
      player.delegate = self
      let height = getHeightOfTableView()
      reloadTableViewHeightConstraint(newHeight: height)
      
      if let track = player.currentTrack?.track {
         presentSmallPlayer(with: track)
      }
   }
   
   //MARK: Public Methods
   init?(
      coder: NSCoder,
      podcast: Podcast,
      playlist: [Podcast],
      player: PlayerInput,
      downloadService: DownloadServiceInput,
      likeManager: LikeManagerInput,
      favouriteManager: FavouriteManagerInput
   ) {
      self.podcast = podcast
      self.podcasts = playlist
      self.player = player
      self.downloadService = downloadService
      self.likeManager = likeManager
      self.favouriteManager = favouriteManager
      
      super.init(coder: coder)
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   //MARK: Public Methods
   func scrollToCell(podcast: Podcast) {
      
      guard let index = podcasts.firstIndex(matching: podcast) else { fatalError() }
      let indexPath = IndexPath(row: index, section: 0)
      let positionOfCell = episodeTableView.getYPositionYFor(indexPath: indexPath)
      let positionOfTableView = episodeTableView.frame.origin.y
      let position = positionOfTableView + positionOfCell
      UIView.animate(withDuration: 12, animations: { [weak self] in
         guard let self = self else { return }
         scrollView.setContentOffset(CGPoint(x: .zero, y: position), animated: true)
      }) { [weak self] _ in
         guard let self = self else { return }
         episodeTableView.openCell(at: indexPath)
      }
   }
   
   //MARK: - Actions
   @IBAction private func backAction(_ sender: UITapGestureRecognizer) {
      dismiss(animated: true)
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
   
   @objc func tapCell(sender: UITapGestureRecognizer) {
      guard let cell = sender.view as? PodcastCell,
            cell.moreThanThreeLines,
            let indexPath = episodeTableView.indexPath(for: cell)
      else { return }
      
      episodeTableView.openCell(at: indexPath)
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
   
   private func presentSmallPlayer(with input: OutputPlayerProtocol) {
      
      if smallPlayerView.isHidden {
         let model = SmallPlayerViewModel(input)
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
      descriptionTextView.text = podcast.descriptionMy
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
      
      let isFavourite = favouriteManager.isFavourite(podcast)
      let isDownloaded = downloadService.isDownloaded(entity: podcast)
      cell.configureCell(episodeTableView, with: podcast, isFavourite: isFavourite, isDownloaded: isDownloaded)
      
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
extension DetailViewController: DownloadServiceDelegate {
   
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
         guard let self = self,
               let podcast = entity as? Podcast else { return }
         
         scrollToCell(podcast: podcast)
      })
   }
}

//MARK: - PlayerEventNotification
extension DetailViewController: PlayerDelegate {
   
   func playerDidEndPlay(_ player: Player, with track: OutputPlayerProtocol) {
      episodeTableView.update(with: track)
   }
   
   func playerStartLoading(_ player: Player, with track: OutputPlayerProtocol) {
      presentSmallPlayer(with: track)
      episodeTableView.update(with: track)
   }
   
   func playerDidEndLoading(_ player: Player, with track: OutputPlayerProtocol) {
      episodeTableView.update(with: track)
   }
   
   func playerUpdatePlayingInformation(_ player: Player, with track: OutputPlayerProtocol) {
      presentSmallPlayer(with: track)
      episodeTableView.update(with: track)
   }
   
   func playerStateDidChanged(_ player: Player, with track: OutputPlayerProtocol) {
      episodeTableView.update(with: track)
   }
}


//MARK: - EpisodeTableViewMyDelegate
extension DetailViewController: EpisodeTableViewMyDelegate {
   
   func episodeTableView(_ episodeTableView: EpisodeTableView, didSelectStar indexPath: IndexPath) {
      let podcast = getPodcast(for: indexPath)
      favouriteManager.addOrRemoveFavouritePodcast(entity: podcast)
   }
   
   func episodeTableView(_ episodeTableView: EpisodeTableView, didSelectDownLoadImage indexPath: IndexPath) {
      let podcast = getPodcast(for: indexPath)
      downloadService.conform(entity: podcast)
   }
   
   func episodeTableView(_ episodeTableView: EpisodeTableView, didTouchPlayButton indexPath: IndexPath) {
      let podcast = getPodcast(for: indexPath)
      player.conform(track: podcast, trackList: podcasts)
   }
   
   func episodeTableView(_ episodeTableView: EpisodeTableView, didTouchStopButton indexPath: IndexPath) {
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
   
   func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
      return 100
   }
}

//MARK: - FavouriteManagerDelegate
extension DetailViewController: FavouriteManagerDelegate {
   
   func favouriteManager(_ favouriteManager: FavouriteManagerInput, didRemove favourite: FavouritePodcast) {
      if let index = podcasts.firstIndex(matching: favourite.podcast) {
         episodeTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
         view.addToast(title: favourite.podcast.isFavourite ? "Add" : "Remove" + " to favourite" , smallPlayerView.isHidden ? .bottom : .bottomWithPlayer)
      }
   }
   
   func favouriteManager(_ favouriteManager: FavouriteManagerInput, didAdd favourite: FavouritePodcast) {
      if let index = podcasts.firstIndex(matching: favourite.podcast) {
         episodeTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
         view.addToast(title: favourite.podcast.isFavourite ? "Add" : "Remove" + " to favourite" , smallPlayerView.isHidden ? .bottom : .bottomWithPlayer)
      }
   }
}
