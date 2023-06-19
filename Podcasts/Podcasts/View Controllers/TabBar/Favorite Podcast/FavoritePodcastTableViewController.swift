//
//  PlaylistTableViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit
import CoreData

protocol FavoritePodcastViewControllerDelegate : AnyObject {
    
    func favoritePodcastTableViewController(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, playlist: [Podcast], podcast: Podcast)
    func favoritePodcastTableViewControllerDidSelectDownLoadImage(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, podcast: Podcast)
    func favoritePodcastTableViewControllerDidSelectStar(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, podcast: Podcast)
    func favoritePodcastTableViewControllerDidSelectCell(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, podcast: Podcast)
//    func favoritePodcastTableViewControllerDidRefreshTableView(_favoritePodcastTableViewController: FavoritePodcastTableViewController)
}

protocol FavoritePodcastViewControllerProtocol {
    var favoritePodcastIsEmpty: Bool { get }
    var favoritePodcastFRC: NSFetchedResultsController<FavoritePodcast> { get }
    func getPodcast(by indexPath: IndexPath) -> Podcast
    func getIndexPath(id: NSNumber?) -> IndexPath?
    func removeAllFavorites()
    func updateFavoritePodcastFromFireBase(completion: ((Result<[FavoritePodcast]>) -> Void)?)
}

protocol FavoritePodcastTableViewPlayableController: PodcastCellPlayableProtocol { }

class FavoritePodcastTableViewController: UIViewController {
    
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, NSManagedObject>
    typealias DiffableDataSource = UITableViewDiffableDataSource<Section, NSManagedObject>
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    weak var delegate: FavoritePodcastViewControllerDelegate?
    private var tableViewBottomConstraintConstant = CGFloat(0)
    private let refreshControl = UIRefreshControl()
    private var searchSection: String? = nil
    
    private let emptyTableImageView: UIImageView = {
        $0.image = UIImage(systemName: "folder")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .lightGray
        return $0
    }(UIImageView())
    
    private var diffableDataSource: DataSource!
    
    private var mySnapShot: SnapShot! = nil
    
    private var playerIsSHidden = true {
        didSet {
            tableViewBottomConstraintConstant = playerIsSHidden ? 0 : 50
            tableViewBottomConstraint?.constant = tableViewBottomConstraintConstant
        }
    }
    
    class DataSource: DiffableDataSource {
        
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return Section[section + 1]
        }
    }
    
    
    enum Section: CaseIterable, Hashable {
        
        case favourite([FavoritePodcast])
        case liked([LikedMoment])
       
        var nameOfSection: String {
            switch self {
            case .favourite(_) :
                return "Favourite"
            case .liked(_):
                return "Liked"
            }
        }
       
        static subscript(_ int: Int) -> String? {
            switch int {
            case 0 : return nil
            case 1: return allCases[0].nameOfSection
            case 2: return allCases[1].nameOfSection
            default: fatalError()
            }
        }
        
        static subscript(getNSManagedObjectBy indexPath: IndexPath) -> NSManagedObject {
           
            switch indexPath.section {
            case 0:
                return favoriteFRC.object(at: IndexPath(item: indexPath.row, section: 0))
            case 1:
                return likeMomentFRC.object(at: IndexPath(item: indexPath.row, section: 0))
            default: fatalError()
            }
        }
        
        
        static subscript(_ indexPath: IndexPath) -> Section {
            switch indexPath.section {
            case 0: return .favourite([])
            case 1: return .liked([])
            default: fatalError()
            }
        }
        
        var identifier: Section {
            switch self {
            case .favourite(_): return .favourite([])
            case .liked(_): return .liked([])
            }
        }
        
        static var favoriteFRC: NSFetchedResultsController<FavoritePodcast> = FavoritePodcast.fetchResultController()
        static var likeMomentFRC: NSFetchedResultsController<LikedMoment> = LikedMoment.likedMomentFRC()
        
        static var allCases: [FavoritePodcastTableViewController.Section] {
            return [
                .favourite(favoriteFRC.fetchedObjects ?? []),
                .liked(likeMomentFRC.fetchedObjects ?? [])
            ]
        }
        
        static var searchText: String? {
            didSet {
                if let searchText = searchText, searchText != "" {
                    let predicate = NSPredicate(format: "podcast.trackName CONTAINS [c] %@", "\(searchText)")
                    self.favoriteFRC.fetchRequest.predicate = predicate
                    self.likeMomentFRC.fetchRequest.predicate = predicate
                } else {
                    self.favoriteFRC = FavoritePodcast.fetchResultController()
                    self.likeMomentFRC = LikedMoment.likedMomentFRC()
                }
                try? favoriteFRC.performFetch()
                try? likeMomentFRC.performFetch()
            }
        }
    }
    
    
    
    
    
    
    
    
    
    //MARK: Variables
    lazy private var searchController: UISearchController = {
        $0.searchBar.placeholder = "Localized.search"
        $0.searchBar.scopeButtonTitles = Section.allCases.map { $0.nameOfSection }
        $0.searchBar.scopeButtonTitles?.insert("All", at: .zero)
        
        $0.searchBar.delegate = self
        $0.searchResultsUpdater = self
        $0.definesPresentationContext = true
        if #available(iOS 16.0, *) {
            $0.scopeBarActivation = .onSearchActivation
        }
        return $0
    }(UISearchController(searchResultsController: nil))
    
    lazy private var removeAllButton: UIBarButtonItem = {
        let button =  UIBarButtonItem(title: "Remova All", primaryAction: UIAction {_ in
            self.removeAllAction()
        })
        return button
    }()
    
    lazy private var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(systemItem: .edit, primaryAction: UIAction {_ in
            self.toggleEditing()
        })
        return button
    }()

    
    //MARK: Public Methods
    func updateConstraintForTableView(playerIsPresent value: Bool) {
        playerIsSHidden = !value
    }
    
    //MARK: View Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showEmptyImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = removeAllButton
        navigationItem.leftBarButtonItem = editButton
        navigationItem.title = "Favorite List"
        
        Section.favoriteFRC.delegate = self
        Section.likeMomentFRC.delegate = self
        addObserverPlayerEventNotification()
        tableViewBottomConstraint.constant = tableViewBottomConstraintConstant
    }

    deinit {
        removeObserverEventNotification()
    }
    
    //MARK: Actions
     private func removeAllAction() {
        FavoritePodcast.removeAll()
    }
    
    @objc func tapFavoritePodcastCell(sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? PodcastCell,
              let podcast = getPodcast(cell) else { return }
       
        self.delegate?.favoritePodcastTableViewControllerDidSelectCell(self, podcast: podcast)
    }
    
    @objc func tapLikedCell(sender: UITapGestureRecognizer) {
        
    }
    
    @objc func refreshTableView() {
        FirebaseDatabase.shared.update { [weak self] (result: FavoritePodcast.ResultType) in
            switch result {
            case .failure(error: let error) :
                error.showAlert(vc: self) {
                    self?.refreshControl.endRefreshing()
                    self?.refreshControl.isHidden = true
                }
            case .success(result: _) :
                self?.refreshControl.endRefreshing()
                self?.refreshControl.isHidden = true
                self?.reloadData()
            }
        }
    }
    
    func toggleEditing() {
        self.tableView.setEditing(!tableView.isEditing, animated: true)
    }
}

//MARK: - Private methods
extension FavoritePodcastTableViewController {
    
    private func configureUI() {
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.backgroundView = emptyTableImageView
        tableView.rowHeight = 100
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.refreshControl = refreshControl
        configureDataSource()
        reloadData()
    }
    
    private func showEmptyImage() {
        let favoritePodcastsIsEmpty = FavoritePodcast.allObjectsFromCoreData.isEmpty
        tableView.backgroundView?.isHidden = favoritePodcastsIsEmpty
        tableView.backgroundView?.isHidden = !favoritePodcastsIsEmpty
        removeAllButton.isEnabled = !favoritePodcastsIsEmpty
    }
    
    private func getPodcast(_ cell: UITableViewCell) -> Podcast? {
        guard let indexPath = tableView.indexPath(for: cell),
              let item = diffableDataSource.itemIdentifier(for: indexPath) else { return nil }
       
        if let favourite = item as? FavoritePodcast {
            return favourite.podcast
        } else if let liked = item as? LikedMoment {
            return liked.podcast
        }
        fatalError()
    }

    
    private func configureDataSource() {
        self.diffableDataSource = DataSource(tableView: tableView) { [weak self] tableView, indexPath, item in
            
            if let favoritePodcast = item as? FavoritePodcast {
                let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
                cell.configureCell(self, with: PodcastCellType(favoritePodcast: favoritePodcast))
                cell.addMyGestureRecognizer(self, type: .tap(), #selector(self?.tapFavoritePodcastCell(sender:)))
                return cell
            }
            
            if let likedMoment = item as? LikedMoment {
                let cell = tableView.getCell(cell: LikedPodcastTableViewCell.self, indexPath: indexPath)
                cell.configureCell(with: likedMoment.podcast)
                cell.addMyGestureRecognizer(self, type: .tap(), #selector(self?.tapLikedCell(sender:)))
                return cell
            }
            assert(false,"must be cell for indexPath")
        }
        self.diffableDataSource.defaultRowAnimation = .fade
    }
    
    
    private func reloadData() {
        self.mySnapShot = SnapShot()
        
        for section in Section.allCases {
            if searchSection == nil || searchSection == section.nameOfSection {
                switch section {
                case .favourite(let items):
                    mySnapShot.appendSections([section.identifier])
                    mySnapShot.appendItems(items)
                case .liked(let items):
                    mySnapShot.appendSections([section.identifier])
                    mySnapShot.appendItems(items)
                }
            }
        }

        self.diffableDataSource.apply(mySnapShot, animatingDifferences: true)
    }
    
    private func updateDownloadInformation(with entity: DownloadServiceType) {
        guard let podcast = entity.downloadProtocol as? Podcast else { return }
        
        if let favoritePodcast = podcast.favoritePodcast {
            if let indexPath = diffableDataSource.indexPath(for: favoritePodcast) {
                if let cell = tableView.cellForRow(at: indexPath) as? PodcastCell {
                    cell.updateDownloadInformation(with: entity)
                    mySnapShot.reloadItems([favoritePodcast])
                }
            }
        }
        
        if let listeningPodcast = podcast.listeningPodcast {
            
        }
        
        if let likedMoment = podcast.likedMoment {
            
        }
    }
    
    private func updatePlayerInformation(with notification: NSNotification) {
        guard let podcast = notification.object as? Podcast,
              let podcast = podcast.getFromCoreData else { return }
        
        if let favoritePodcast = podcast.favoritePodcast {
            if let indexPath = diffableDataSource.indexPath(for: favoritePodcast) {
                if let cell = tableView.cellForRow(at: indexPath) as? PodcastCell {
//                    cell.updatePlayerInformation(with: PodcastCellPlayableProtocol)
                    mySnapShot.reloadItems([favoritePodcast])
                }
            }
        }
        
        if let listeningPodcast = podcast.listeningPodcast {
            
        }
        
        if let likedMoment = podcast.likedMoment {
            
        }
        
    }
}

//MARK: - PodcastCellDelegate
extension FavoritePodcastTableViewController: PodcastCellDelegate {
    
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell, entity: PodcastCellType) {
        guard let podcast = getPodcast(podcastCell) else { return }
        delegate?.favoritePodcastTableViewControllerDidSelectStar(self, podcast: podcast)
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell, entity: PodcastCellType) {
        guard let podcast = getPodcast(podcastCell) else { return }
        delegate?.favoritePodcastTableViewControllerDidSelectDownLoadImage(self, podcast: podcast)
    }
    
    func podcastCellDidTouchPlayButton(_ podcastCell: PodcastCell, entity: PodcastCellType) {
        guard let podcast = getPodcast(podcastCell) else { return }
        
        let podcasts = Section.favoriteFRC.fetchedObjects?.map { $0.podcast } ?? []
        let playlist = podcasts.filter { $0.identifier != podcast.identifier }
        
        delegate?.favoritePodcastTableViewController(self, playlist: playlist, podcast: podcast)
    }
    
    func podcastCellDidTouchStopButton(_ podcastCell: PodcastCell, entity: PodcastCellType) {  }
    
    func podcastCellDidSelectStar(_ podcast: Podcast, podcastCell: PodcastCell) { }
}


//MARK: - NSFetchedResultsControllerDelegate
extension FavoritePodcastTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
            
        case .delete:
            guard let indexPath = indexPath else { return }
            guard let item = diffableDataSource.itemIdentifier(for: indexPath) else { return }
            mySnapShot.deleteItems([item])

        case .insert:
            guard let indexPath = newIndexPath else { return }
            let item = Section[getNSManagedObjectBy: indexPath]
            if let oldItem = diffableDataSource.itemIdentifier(for: indexPath) {
                mySnapShot.insertItems([item], beforeItem: oldItem)
            } else {
                mySnapShot.appendItems([item], toSection: Section[indexPath])
            }
            
        default : break
        }
        
        diffableDataSource.apply(mySnapShot)
        showEmptyImage()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
}

//MARK: - UISearchResultsUpdating
extension FavoritePodcastTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        if searchText != "" || Section.searchText != nil {
            Section.searchText = searchText
        }
    }
}

//MARK: - UISearchBarDelegate
extension FavoritePodcastTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.searchSection = Section[selectedScope]
        self.reloadData()
    }
}

//MARK: - DownloadServiceDelegate
extension FavoritePodcastTableViewController: DownloadServiceDelegate {
    
    func didRemoveEntity(_ downloadService: DownloadService, entity: DownloadServiceType) {
        updateDownloadInformation(with: entity)
    }

    func updateDownloadInformation(_ downloadService: DownloadService, entity: DownloadServiceType) {
        updateDownloadInformation(with: entity)
    }
    
    func didEndDownloading(_ downloadService: DownloadService, entity: DownloadServiceType) {
        updateDownloadInformation(with: entity)
    }
    
    func didPauseDownload(_ downloadService: DownloadService, entity: DownloadServiceType) {
        updateDownloadInformation(with: entity)
    }
    
    func didContinueDownload(_ downloadService: DownloadService, entity: DownloadServiceType) {
        updateDownloadInformation(with: entity)
    }
    
    func didStartDownload(_ downloadService: DownloadService, entity: DownloadServiceType) {
        updateDownloadInformation(with: entity)
    }
}

extension FavoritePodcastTableViewController: PlayerEventNotification {
    
    func addObserverPlayerEventNotification() {
        Player.addObserverPlayerPlayerEventNotification(for: self)
    }
    
    func removeObserverEventNotification() {
        Player.removeObserverEventNotification(for: self)
    }
    
    func playerDidEndPlay(notification: NSNotification) {
        updatePlayerInformation(with: notification)
    }
    
    func playerStartLoading(notification: NSNotification) {
        updatePlayerInformation(with: notification)
    }
    
    func playerDidEndLoading(notification: NSNotification) {
        updatePlayerInformation(with: notification)
    }
    
    func playerUpdatePlayingInformation(notification: NSNotification) {
        updatePlayerInformation(with: notification)
    }
    
    func playerStateDidChanged(notification: NSNotification) {
        updatePlayerInformation(with: notification)
    }
}
