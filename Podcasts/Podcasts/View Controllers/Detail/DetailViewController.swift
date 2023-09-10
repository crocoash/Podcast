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
   
   @IBOutlet private weak var sortButton: UIButton!
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
   
   enum TypeSortOfTableView: String {
      case byNewest = "by newest"
      case byOldest = "by oldest"
      case byGenre = "by genres"
   }
   
   lazy private var typeOfSort: TypeSortOfTableView = .byNewest {
      didSet {
         configurePlaylist()
         configureSortButton()
         configureSortMenu()
      }
   }
   
   private var playlist: [(key: AnyHashable, rows: [(any (Identifiable & AnyObject))])] = []
   
   //MARK: View Methods
   override func viewDidLoad() {
      super.viewDidLoad()
      configureGestures()
     
      setupView()
      
      let height = episodeTableView.height
      reloadTableViewHeightConstraint(newHeight: height)
      
      if let track = player.currentTrack?.track {
         presentSmallPlayer(with: track)
      }
   }
   
   //MARK: Public Methods
   init?(
      coder: NSCoder,
      podcast: Podcast,
      podcasts: [Podcast],
      player: PlayerInput,
      downloadService: DownloadServiceInput,
      likeManager: LikeManagerInput,
      favouriteManager: FavouriteManagerInput
   ) {
      self.podcast = podcast
      self.podcasts = podcasts
      self.player = player
      self.downloadService = downloadService
      self.likeManager = likeManager
      self.favouriteManager = favouriteManager
      
      super.init(coder: coder)
      
      self.downloadService.delegate = self
      self.favouriteManager.delegate = self
      self.player.delegate = self
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
      typeOfSort = .byGenre
      configureSortMenu()
   }
   
   @IBAction private func refreshByNewest(_ sender: UICommand) {
      typeOfSort = .byNewest
      configureSortMenu()
   }
   
   @IBAction private func refreshByOldest(_ sender: UICommand) {
      typeOfSort = .byOldest
      configureSortMenu()
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
   
   private func configureSortButton() {
      sortButton.setTitle(typeOfSort.rawValue, for: .normal)
   }
   
   private func configureSortMenu() {
      sortButton.menu?.children.forEach {
         ($0 as! UICommand).state = $0.title == typeOfSort.rawValue ? .on : .off
      }
   }
   
   private func configurePlaylist() {
      var playlist: [(key: AnyHashable, rows: [(any (Identifiable & AnyObject))])] = self.playlist
      switch typeOfSort {
      case .byGenre:
         playlist = podcasts.sortPodcastsByGenre
      case .byNewest:
         playlist = podcasts.sortPodcastsByNewest
      case .byOldest:
         playlist = podcasts.sortPodcastsByOldest
      }
      conformPlaylist(by: playlist)
   }
   
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
      
      episodeTableView.translatesAutoresizingMaskIntoConstraints = false
      
      configurePlaylist()
      configureSortButton()
      configureSortMenu()
      
      episodeName        .text = podcast.trackName
      artistName         .text = podcast.artistName ?? "Artist Name"
      genresLabel        .text = podcast.genresString
      descriptionTextView.text = podcast.descriptionMy
      countryLabel       .text = podcast.country
      advisoryRatingLabel.text = podcast.contentAdvisoryRating
      dateLabel          .text = podcast.releaseDateInformation.formattedDate(dateFormat: "d MMM YYY")
      durationLabel      .text = podcast.trackTimeMillis?.minute
   }
   
   //[(key: AnyHashable, rows: [(any (Identifiable & AnyObject))])]
   
   private func conformPlaylist(by newPlayList: [(key: AnyHashable, rows: [(any (Identifiable & AnyObject))])]) {
      
      (newPlayList as [(key: AnyHashable, rows: [(any (Identifiable & AnyObject))])])
         .conform(self.playlist,
                   removeSection: { index in
            playlist.remove(at: index)
            episodeTableView.deleteSections(IndexSet([index]), with: .automatic)
         }, removeItem: { indexPath in
            playlist[indexPath.section].rows.remove(at: indexPath.row)
            episodeTableView.deleteRows(at: [indexPath], with: .automatic)
         }, insertSection: { section, index in
            playlist.insert(section, at: index)
            episodeTableView.insertSections(IndexSet([index]), with: .right)
         }, insertItem: { indexPath, row in
            playlist[indexPath.section].rows.insert(row, at: indexPath.row)
            episodeTableView.insertRows(at: [indexPath], with: .automatic)
         })
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

//MARK: - PlayerDelegate
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
      let podcast = playlist[indexPath.section].rows[indexPath.row] as! Podcast
       let isFavourite = favouriteManager.isFavourite(podcast)
       if isFavourite {
           favouriteManager.removeFavouritePodcast(entity: podcast)
       } else {
           favouriteManager.addFavouritePodcast(entity: podcast)
       }
   }
   
   func episodeTableView(_ episodeTableView: EpisodeTableView, didSelectDownLoadImage indexPath: IndexPath) {
      let podcast = playlist[indexPath.section].rows[indexPath.row] as! Podcast
      downloadService.conform(entity: podcast)
   }
   
   func episodeTableView(_ episodeTableView: EpisodeTableView, didTouchPlayButton indexPath: IndexPath) {
      let podcast = playlist[indexPath.section].rows[indexPath.row] as! Podcast
      player.conform(track: podcast, trackList: podcasts)
   }
   
   func episodeTableView(_ episodeTableView: EpisodeTableView, didTouchStopButton indexPath: IndexPath) {
      player.playOrPause()
   }
}

//MARK: - UITableViewDataSource
extension DetailViewController: UITableViewDataSource {
   
   func numberOfSections(in tableView: UITableView) -> Int {
      return playlist.count
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return playlist[section].rows.count
   }
   
   func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return playlist[section].key as? String ?? ""
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
      let podcast = playlist[indexPath.section].rows[indexPath.row] as! Podcast
      
      cell.addMyGestureRecognizer(self, type: .tap(), #selector(tapCell))
      
      let isFavourite = favouriteManager.isFavourite(podcast)
      let isDownloaded = downloadService.isDownloaded(entity: podcast)
      
      cell.configureCell(episodeTableView, with: podcast, isFavourite: isFavourite, isDownloaded: isDownloaded)
      
      return cell
   }
}

//MARK: - EpisodeTableViewControllerMyDataSource
extension DetailViewController: EpisodeTableViewMyDataSource {

   func episodeTableViewDidChangeHeightTableView(_ episodeTableView: EpisodeTableView, height: CGFloat, withLastCell isLastCell: Bool) {
      if isLastCell {
         UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self, let view = view else { return }
            reloadTableViewHeightConstraint(newHeight: height)

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

//MARK: - FavouriteManagerDelegate
extension DetailViewController: FavouriteManagerDelegate {
   
   func favouriteManager(_ favouriteManager: FavouriteManagerInput, didRemove favourite: FavouritePodcast) {
      if let indexPath = playlist[favourite.podcast] {
         episodeTableView.reloadRows(at: [indexPath], with: .automatic)
          
         view.addToast(title: favourite.podcast.isFavourite ? "Add" : "Remove" + " to favourite" , smallPlayerView.isHidden ? .bottom : .bottomWithPlayer)
      }
   }
   
   func favouriteManager(_ favouriteManager: FavouriteManagerInput, didAdd favourite: FavouritePodcast) {
      if let indexPath = playlist[favourite.podcast]  {
         episodeTableView.reloadRows(at: [indexPath], with: .automatic)
         view.addToast(title: favourite.podcast.isFavourite ? "Add" : "Remove" + " to favourite" , smallPlayerView.isHidden ? .bottom : .bottomWithPlayer)
      }
       
    
   }
}

//MARK: - ++++++++++++++++

extension Collection where Element == (key: (AnyHashable), rows: [(any (Identifiable & AnyObject))]) {
   
    subscript(_ entity: (any (Identifiable & AnyObject))) -> IndexPath? {
        for (sectionIndex, section) in self.enumerated() {
            for (rowIndex, row) in section.rows.enumerated() {
                print("\(entity.id )")
                print("\(row.id )")
                if let idString = entity.id as? String {
                    if let rowId = row.id as? String {
                        if idString == rowId {
                            return IndexPath(row: rowIndex, section: sectionIndex)
                        }
                    }
                }
            }
        }
        return nil
    }
    
    
   func conform(_ playlist: [Element],
                removeSection: ((_ index: Int) -> ()),
                removeItem: ((_ indexPath: IndexPath) -> ()),
                insertSection: ((_ section: Element,_ index: Int) -> ()),
                insertItem: ((_ indexPath: IndexPath,_ row: (any (Identifiable & AnyObject))) -> ())) {
      
      var playlist: [Element] = playlist
      
      playlist.enumerated { indexSection, section in
         
         let newSections = self.map { $0.key }
         
         if newSections.isEmpty || !newSections.contains(section.key) {
            if let index = playlist.firstIndex(where: { $0.key == section.key }) {
               playlist.remove(at: index)
               removeSection(index)
            }
         } else {
            for row in section.rows {
               self.enumerated { newIndexSection, newSection in
                  if newSection.key == section.key  {
                     if let index = playlist[indexSection].rows.firstIndex(where: { $0.id == row.id })  {
                        playlist[indexSection].rows.remove(at: index)
                        removeItem(IndexPath(item: index, section: indexSection))
                     }
                  }
               }
            }
         }
//
//         if section.rows.isEmpty {
//            playlist.remove(at: indexSection)
//            removeSection(indexSection)
//         }
      }
         
      /// append
      self.enumerated { indexNewSection, newSection in
         
         newSection.rows.enumerated { indexNewRow, newRow in
            
            if !playlist.contains(where: { $0.key == newSection.key }) {
               let index = playlist.count
               playlist.insert((key: newSection.key, rows: [newRow]), at: index)
               insertSection((key: newSection.key, rows: [newRow]), indexNewSection)
            } else {
               playlist.enumerated { indexSection, section in
                  if newSection.key == section.key {
                     if !section.rows.contains(where: { $0.id == newRow.id }) {
                        let index = section.rows.count == 0 ? 0 : (section.rows.count - 1)
                        let indexPath = IndexPath(row: index, section: indexSection)
                        playlist[indexSection].rows.insert(newRow, at: index)
                        insertItem(indexPath, newRow)
                     }
                  }
               }
            }
         }
      }
   }
}

