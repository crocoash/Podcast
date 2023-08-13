//
//  PlaylistTableViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit
import CoreData

protocol ListViewControllerDelegate: AnyObject {
    func listViewController(_ listViewController: ListViewController, didSelect podcast: Podcast)
}

class ListViewController: UIViewController {
    
    private var downloadService: DownloadServiceInput
    private var player: InputPlayer
    private let firebaseDataBase: FirebaseDatabaseInput
    private let favoriteManager: FavoriteManagerInput
    private let dataStoreManager: DataStoreManagerInput
    private let listeningManager: ListeningManagerInput
    weak var delegate: ListViewControllerDelegate?
    
    private let refreshControl = UIRefreshControl()
    private var bottomTableViewConstraint: NSLayoutConstraint?
    private var searchSection: String? = nil
    
    lazy private var favoriteTableView: FavoriteTableView = {
        let tableView = FavoriteTableView(self)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.refreshControl = refreshControl
        return tableView
    }()
    
    lazy var favoriteFRC = dataStoreManager.conFigureFRC(for: FavoritePodcast.self, with: nil)
    lazy var likeMomentFRC = dataStoreManager.conFigureFRC(for: LikedMoment.self, with: nil)
    lazy var listeningFRC = dataStoreManager.conFigureFRC(for: ListeningPodcast.self, with: nil)
    
    private var model: ListViewModel!
    
    //MARK: init
    init<T: ListViewControllerDelegate>(_ vc: T,
                                            downloadService: DownloadServiceInput,
                                            player: InputPlayer,
                                            favoriteManager: FavoriteManagerInput,
                                            firebaseDataBase: FirebaseDatabaseInput,
                                            dataStoreManager: DataStoreManagerInput,
                                        listeningManager: ListeningManagerInput) {
        
        self.downloadService = downloadService
        self.player = player
        self.favoriteManager = favoriteManager
        self.firebaseDataBase = firebaseDataBase
        self.dataStoreManager = dataStoreManager
        self.delegate = vc
        self.listeningManager = listeningManager
        
        super.init(nibName: nil, bundle: nil)
        
        favoriteFRC.delegate = self
        likeMomentFRC.delegate = self
        listeningFRC.delegate = self
            
        let sections: [[NSManagedObject]] = [favoriteFRC.fetchedObjects ?? [],
                                          listeningFRC.fetchedObjects ?? [],
                                          likeMomentFRC.fetchedObjects ?? []].filter( { !$0.isEmpty })
        
//        (favoriteFRC.fetchedObjects ?? []).forEach {
//            if let podcast = $0.podcast.listeningPodcast?.podcast {
//                podcast.observeValue(forKeyPath: #keyPath(Podcast.listeningPodcast), of: nil, change: nil, context: nil)
//            }
//        }
//       
        self.model = ListViewModel(entities: sections)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var searchText: String? {
        didSet {
            if let searchText = searchText, searchText != "" {
                let predicate = NSPredicate(format: "podcast.trackName CONTAINS [c] %@", "\(searchText)")
                self.favoriteFRC.fetchRequest.predicate = predicate
                self.likeMomentFRC.fetchRequest.predicate = predicate
                self.listeningFRC.fetchRequest.predicate = predicate
            } else {
                self.favoriteFRC.fetchRequest.predicate = nil
                self.likeMomentFRC.fetchRequest.predicate = nil
                self.listeningFRC.fetchRequest.predicate = nil
            }
            try? favoriteFRC.performFetch()
            try? likeMomentFRC.performFetch()
            try? listeningFRC.performFetch()
        }
    }
    
    //MARK: Variables
    lazy private var searchController: UISearchController = {
        $0.searchBar.placeholder = "Localized.search"
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
    
    func toggleEditing() {
        favoriteTableView.setEditing(!favoriteTableView.isEditing, animated: true)
    }
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = removeAllButton
        navigationItem.leftBarButtonItem = editButton
        navigationItem.title = "Favorite List"
        
        player.delegate = self
        downloadService.delegate = self
        
        view.addSubview(favoriteTableView)
        
        self.bottomTableViewConstraint = view.bottomAnchor.constraint(equalTo: favoriteTableView.bottomAnchor, constant: heightTabBarItem)
        self.bottomTableViewConstraint?.isActive = true
        
        favoriteTableView.leadingAnchor .constraint(equalTo: view.leadingAnchor).isActive = true
        favoriteTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        favoriteTableView.topAnchor     .constraint(equalTo: view.topAnchor).isActive = true
    }
    
    private var playerIsSHidden: Bool = true {
        didSet {
            bottomTableViewConstraint?.constant = heightTabBarItem + (playerIsSHidden ? 0 : 50)
        }
    }
    
    lazy private var heightTabBarItem = tabBarController?.tabBar.frame.height ?? 0
    
    //MARK: Actions
    @objc func tapFavoritePodcastCell(sender: UITapGestureRecognizer) {
        
        guard let cell = sender.view as? UITableViewCell,
              let indexPath = favoriteTableView.indexPath(for: cell),
              let favoritePodcast = model.getObject(for: indexPath) as? FavoritePodcast else { return }
        
        
        delegate?.listViewController(self, didSelect: favoritePodcast.podcast)
    }
    
    @objc func removeListeningPodcast(sender: UILongPressGestureRecognizer) {
        guard let cell = sender.view as? UITableViewCell,
              let indexPath = favoriteTableView.indexPath(for: cell),
              let listeningPodcast = model.getObject(for: indexPath) as? ListeningPodcast else { return }
        
        listeningManager.removeListeningPodcast(listeningPodcast)
    }
    
    @objc func refreshTableView() {
        let viewContext = dataStoreManager.viewContext
        
        firebaseDataBase.update(viewContext: viewContext) { [weak self] (result: FavoritePodcast.ResultType) in
            switch result {
            case .failure(error: let error) :
                error.showAlert(vc: self)
            default: break
            }
        }
        
        firebaseDataBase.update(viewContext: viewContext) { [weak self] (result: ListeningPodcast.ResultType) in
            
            guard let self = self else { return }
            
            switch result {
            case .failure(error: let error) :
                error.showAlert(vc: self) {
                }
            default: break
            }
            
            refreshControl.endRefreshing()
            refreshControl.isHidden = true
        }
    }
}

//MARK: - Private methods
extension ListViewController {
    
    private func removeAllAction() {
        favoriteManager.removeAll()
    }
    
    private func configureCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        
        let item = model.getObject(for: indexPath)
        
        if let item = item as? FavoritePodcast {
            let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
            
            let isFavorite = true
            let isDownloaded = downloadService.isDownloaded(entity: item)
            
            cell.configureCell(self, with: item, isFavorite: isFavorite, isDownloaded: isDownloaded)
            cell.addMyGestureRecognizer(self, type: .tap(), #selector(tapFavoritePodcastCell(sender:)))
            return cell
        } else if let item = item as? LikedMoment {
            let cell = tableView.getCell(cell: LikedPodcastTableViewCell.self, indexPath: indexPath)
            cell.configureCell(with: item.podcast)
            return cell
        } else if let item = item as? ListeningPodcast {
            let cell = tableView.getCell(cell: ListeningPodcastCell.self, indexPath: indexPath)
            cell.addMyGestureRecognizer(self, type: .longPressGesture(minimumPressDuration: 1), #selector(removeListeningPodcast(sender:)))
            cell.configure(with: item)
            return cell
        }
        fatalError()
    }
}


//MARK: - UISearchResultsUpdating
extension ListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        //        let searchText = searchController.searchBar.text
        //        if searchText != "" || Section.searchText != nil {
        //            Section.searchText = searchText
        //        }
        //
        favoriteTableView.reloadData()
    }
}

//MARK: - UISearchBarDelegate
extension ListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //        self.searchSection = Section[selectedScope]
        self.favoriteTableView.reloadData()
    }
}

//MARK: - PlayerEventNotification
extension ListViewController: PlayerDelegate {
    
    func playerDidEndPlay(with track: OutputPlayerProtocol) {
        favoriteTableView.updateTableView(with: track)
    }
    
    func playerStartLoading(with track: OutputPlayerProtocol) {
        favoriteTableView.updateTableView(with: track)
    }
    
    func playerDidEndLoading(with track: OutputPlayerProtocol) {
        favoriteTableView.updateTableView(with: track)
    }
    
    func playerUpdatePlayingInformation(with track: OutputPlayerProtocol) {
        favoriteTableView.updateTableView(with: track)
    }
    
    func playerStateDidChanged(with track: OutputPlayerProtocol) {
        favoriteTableView.updateTableView(with: track)
    }
}

//MARK: - DownloadEventNotifications
extension ListViewController: DownloadServiceDelegate {
    
    func updateDownloadInformation(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        favoriteTableView.updateTableView(with: entity)
    }
    
    func didEndDownloading(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        favoriteTableView.updateTableView(with: entity)
    }
    
    func didPauseDownload(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        favoriteTableView.updateTableView(with: entity)
    }
    
    func didContinueDownload(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        favoriteTableView.updateTableView(with: entity)
    }
    
    func didStartDownload(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        favoriteTableView.updateTableView(with: entity)
    }
    
    func didRemoveEntity(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        favoriteTableView.updateTableView(with: entity)
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension ListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        favoriteTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .delete:
            guard var indexPath = indexPath,
                  let section = model.getIndexOfSection(forAny: anObject) else { return }
           
            indexPath.section = section
            
            model.remove(anObject)
            favoriteTableView.deleteItem(at: indexPath)
            
            if let favoritePodcast = anObject as? FavoritePodcast {
                let name = favoritePodcast.podcast.trackName ?? ""
                let title = "\(name) podcast is added to playlist"
                addToast(title: title, (playerIsSHidden ? .bottom : .bottomWithPlayer))
            }
           
        case .insert:
            
            guard var newIndexPath = newIndexPath else { return }
            
            model.appendItem(anObject, at: newIndexPath.row)
            
            guard let section = model.getIndexOfSection(forAny: anObject) else { return }
            
            newIndexPath.section = section
            
            let isFirstElementInSection = model.isFirstElementInSection(at: newIndexPath)
            let isLastSection = model.isLastSection(at: newIndexPath)
            let isOnlyOneSection = model.isOnlyOneSection
            
            var insertSection = ""
            
            if isFirstElementInSection, !isOnlyOneSection {
                if isLastSection {
                    insertSection = model.getNameOfSection(for: newIndexPath.section - 1) ?? ""
                } else {
                    insertSection = model.getNameOfSection(for: newIndexPath.section + 1) ?? ""
                }
            }
            
            favoriteTableView.insertCell(isLast: isLastSection, insertSection: insertSection, at: newIndexPath, before: indexPath)
            
            if let favoritePodcast = anObject as? FavoritePodcast {
                let name = favoritePodcast.podcast.trackName ?? ""
                let title = "\(name) podcast is added to playlist"
                addToast(title: title, (playerIsSHidden ? .bottom : .bottomWithPlayer))
            }
           
        default : break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        favoriteTableView.endUpdates()
    }
}

//MARK: - FavoriteTableDataSource
extension ListViewController: FavoriteTableDataSource {
    
    func favoriteTableView(_ favoriteTableView: FavoriteTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(for: favoriteTableView, at: indexPath)
    }
    
    func favoriteTableViewCountOfSections(_ favoriteTableView: FavoriteTableView) -> Int {
        return model.countOfSections
    }
    
    func favoriteTableView(_ favoriteTableView: FavoriteTableView, countOfRowsInSection index: Int) -> Int {
        return model.getCountOfRowsInSection(section: index)
    }
    
    func favoriteTableView(_ favoriteTableView: FavoriteTableView, nameOfSectionFor index: Int) -> String {
        return model.getNameOfSection(for: index) ?? "dwdweqd"
    }
}

//MARK: - PodcastCellDelegate
extension ListViewController: PodcastCellDelegate {
    
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell) {
        guard let indexPath = favoriteTableView.indexPath(for: podcastCell),
              let favoritePodcast = model.getObject(for: indexPath) as? FavoritePodcast else { return }
        
        favoriteManager.addOrRemoveFavoritePodcast(entity: favoritePodcast.podcast)
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell) {
        guard let indexPath = favoriteTableView.indexPath(for: podcastCell) else { return }
        guard let entity = model.getObject(for: indexPath) as? InputDownloadProtocol else { return }
        downloadService.conform(entity: entity)
    }
    
    func podcastCellDidTouchPlayButton(_ podcastCell: PodcastCell) {
        guard let indexPath = favoriteTableView.indexPath(for: podcastCell),
              let favoritePodcast = model.getObject(for: indexPath) as? FavoritePodcast,
              let favoritePodcasts = model.getObjects(for: indexPath) as? [FavoritePodcast] else { fatalError() }
        
        player.conform(track: favoritePodcast.podcast, trackList: favoritePodcasts.map { $0.podcast })
    }
    
    func podcastCellDidTouchStopButton(_ podcastCell: PodcastCell) {
        player.playOrPause()
    }
}
