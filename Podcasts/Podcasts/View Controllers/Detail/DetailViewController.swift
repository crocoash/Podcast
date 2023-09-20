//
//  DetailViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, IHaveStoryBoard {
    
    typealias Args = (podcast: Podcast, podcasts: [Podcast])
   
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
   private(set) var podcasts: [Podcast] = []
   
   private var player: Player
   private var downloadService: DownloadService
   private var bigPlayerViewController: BigPlayerViewController?
   private var likeManager: LikeManager
   private var favouriteManager: FavouriteManager
   private var container: IContainer
   
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
    required init?(container: IContainer, args: (args: (podcast: Podcast, podcasts: [Podcast]), coder: NSCoder)) {
   
        self.player = container.resolve()
        self.downloadService = container.resolve()
        self.likeManager = container.resolve()
        self.favouriteManager = container.resolve()
        self.container = container
        
        self.podcast = args.args.podcast
        self.podcasts = args.args.podcasts
        
        super.init(coder: args.coder)

        self.favouriteManager.delegate = self
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
   
   private func presentSmallPlayer(with viewModel: any OutputPlayerProtocol) {
      
      if smallPlayerView.isHidden {
         let model = SmallPlayerViewModel(viewModel)
          self.smallPlayerView.configure(with: model, player: player)
         smallPlayerView.isHidden = false
         bottomPlayerConstraint.constant = 50
         view.layoutIfNeeded()
      }
   }
   
   private func presentBigPlayer(with track: Track) {
       let argsVM: BigPlayerViewModel.Arguments = track
       let args: BigPlayerViewController.Arguments = self
       let bigPlayerViewController: BigPlayerViewController = container.resolveWithModel(args: args, argsVM: argsVM)
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
   
   func playerDidEndPlay(_ player: Player, with track: any OutputPlayerProtocol) {}
   
   func playerStartLoading(_ player: Player, with track: any OutputPlayerProtocol) {
      presentSmallPlayer(with: track)
   }
   
   func playerDidEndLoading(_ player: Player, with track: any OutputPlayerProtocol) {}
   
   func playerUpdatePlayingInformation(_ player: Player, with track: any OutputPlayerProtocol) {}
   
   func playerStateDidChanged(_ player: Player, with track: any OutputPlayerProtocol) {}
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
        let args = PodcastCellViewModel.Arguments.init(podcast: podcast, playlist: podcasts)
        cell.viewModel = container.resolve(args: args)
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
    
    func favouriteManager(_ favouriteManager: FavouriteManager, didRemove favourite: FavouritePodcast) {
        view.addToast(title: "Remove from favourite" , smallPlayerView.isHidden ? .bottom : .bottomWithPlayer)
    }
    
    func favouriteManager(_ favouriteManager: FavouriteManager, didAdd favourite: FavouritePodcast) {
        view.addToast(title: "Add to favourite" , smallPlayerView.isHidden ? .bottom : .bottomWithPlayer)
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

