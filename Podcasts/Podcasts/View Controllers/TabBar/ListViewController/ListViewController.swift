//
//  PlaylistTableViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit
import CoreData

//MARK: - Delegate
protocol ListViewControllerDelegate: AnyObject {
    func listViewController(_ listViewController: ListViewController, didSelect podcast: Podcast)
}

class ListViewController: UIViewController {
    
    //MARK: services
    private var downloadService:  DownloadServiceInput
    private var player:           PlayerInput
    private let firebaseDataBase: FirebaseDatabaseInput
    private let favouriteManager: FavouriteManagerInput
    private let dataStoreManager: DataStoreManagerInput
    private let listeningManager: ListeningManagerInput
    
    lazy private var listDataManager: ListDataManagerInput = ListDataManager(dataStoreManager: dataStoreManager, firebaseDatabase: firebaseDataBase)
    
    weak var delegate: ListViewControllerDelegate?
    
    private let refreshControl = UIRefreshControl()
    private var alertTopConstraint: NSLayoutConstraint?
    
    private var playerIsSHidden: Bool = true
    
    lazy private var heightTabBarItem = tabBarController?.tabBar.frame.height ?? 0
    
    //MARK: Outlets
    @IBOutlet private weak var favouriteTableView: FavouriteTableView!
    @IBOutlet private weak var bottomTableViewConstraint: NSLayoutConstraint!
    
    private var alertSortListView: AlertSortListView?
    
    lazy private var model = ListViewModel(vc: self, dataStoreManager: dataStoreManager, listDataManager: listDataManager)
    
    //MARK: init
    init?<T: ListViewControllerDelegate>(coder: NSCoder,
                                         _ vc: T,
                                         downloadService: DownloadServiceInput,
                                         player: PlayerInput,
                                         favouriteManager: FavouriteManagerInput,
                                         firebaseDataBase: FirebaseDatabaseInput,
                                         dataStoreManager: DataStoreManagerInput,
                                         listeningManager: ListeningManagerInput) {
        
        self.downloadService = downloadService
        self.player = player
        self.favouriteManager = favouriteManager
        self.firebaseDataBase = firebaseDataBase
        self.dataStoreManager = dataStoreManager
        self.delegate = vc
        self.listeningManager = listeningManager
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Variables
    lazy private var searchController: UISearchController = {
        $0.searchBar.placeholder = "Localized.search"
        $0.searchBar.delegate = self
        $0.definesPresentationContext = true
        if #available(iOS 16.0, *) {
            $0.scopeBarActivation = .onSearchActivation
        }
        return $0
    }(UISearchController(searchResultsController: nil))
    
    lazy private var removeAllButton: UIBarButtonItem = {
        let button =  UIBarButtonItem(title: "Remova All", primaryAction: UIAction { [weak self] _ in
            guard let self = self else { return }
            removeAllAction()
        })
        return button
    }()
    
    lazy private var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(systemItem: .edit, primaryAction: UIAction { [weak self] _ in
            guard let self = self else { return }
            editButtonDidTouch()
        })
        return button
    }()
    
    //MARK: Public Methods
    func updateConstraintForTableView(playerIsPresent value: Bool) {
        playerIsSHidden = !value
        bottomTableViewConstraint?.constant = playerIsSHidden ? 0 : 50
    }
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.delegate = self
        downloadService.delegate = self
        
        configureNavigationItem()
        configureAlertSortListView()
    }
    
    //MARK: Actions
    @objc private func tapFavouritePodcastCell(sender: UITapGestureRecognizer) {
        
        guard let cell = sender.view as? UITableViewCell,
              let indexPath = favouriteTableView.indexPath(for: cell),
              let favouritePodcast = model.getObjectInSection(for: indexPath) as? FavouritePodcast else { return }
        
        delegate?.listViewController(self, didSelect: favouritePodcast.podcast)
    }
    
    @objc private func removeListeningPodcast(sender: UILongPressGestureRecognizer) {
        guard let cell = sender.view as? UITableViewCell,
              let indexPath = favouriteTableView.indexPath(for: cell),
              let listeningPodcast = model.getObjectInSection(for: indexPath) as? ListeningPodcast else { return }
        
        listeningManager.removeListeningPodcast(listeningPodcast)
    }
    
    private func editButtonDidTouch() {
        guard let alertSortListView = alertSortListView else { fatalError() }
        alertSortListView.showOrHideAlertListView()
    }
    
    private func removeAllAction() {
        favouriteManager.removeAll()
    }
}

//MARK: - Private methods
extension ListViewController {
    
    private func configureNavigationItem() {
        navigationItem.searchController = searchController
        configureScopeBar()
        navigationItem.rightBarButtonItem = removeAllButton
        navigationItem.leftBarButtonItem = editButton
        navigationItem.title = "Favourite List"
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func configureScopeBar() {
        searchController.searchBar.scopeButtonTitles = model.nameOfActiveSections
        searchController.searchBar.scopeButtonTitles?.insert("All", at: .zero)
    }
    
    private func configureAlertSortListView() {
        guard let tabBarController = tabBarController else { fatalError() }
        
        let vc = AlertSortListView(vc: self, dataStoreManager: dataStoreManager, listDataManager: listDataManager)
        tabBarController.view.addSubview(vc)
        
        alertSortListView = vc
    }
    
    private func configureCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        
        let item = model.getObjectInSection(for: indexPath)
        
        if let item = item as? FavouritePodcast {
            let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
            
            let isFavourite = true
            let isDownloaded = downloadService.isDownloaded(entity: item)
            
            cell.configureCell(self, with: item, isFavourite: isFavourite, isDownloaded: isDownloaded)
            cell.addMyGestureRecognizer(self, type: .tap(), #selector(tapFavouritePodcastCell(sender:)))
            return cell
        } else if let item = item as? LikedMoment {
            let cell = tableView.getCell(cell: LikedPodcastTableViewCell.self, indexPath: indexPath)
            cell.configureCell(with: item.podcast)
            return cell
        } else if let item = item as? ListeningPodcast {
            let cell = tableView.getCell(cell: ListeningPodcastCell.self, indexPath: indexPath)
            cell.addMyGestureRecognizer(self, type: .longPressGesture(minimumPressDuration: 1), #selector(removeListeningPodcast(sender:)))
            let model = ListeningPodcastCellModel(item)
            cell.configure(with: model)
            return cell
        }
        fatalError()
    }
    
    private func refreshTableView(completion: @escaping () -> ()) {
        let viewContext = dataStoreManager.viewContext
        
        firebaseDataBase.update(viewContext: viewContext) { [weak self] (result: FavouritePodcast.ResultType) in
            guard let self = self else { return }
            
            switch result {
            case .failure(error: let error) :
                error.showAlert(vc: self)
            default: break
            }
            
            firebaseDataBase.update(viewContext: viewContext) { [weak self] (result: ListeningPodcast.ResultType) in
                
                guard let self = self else { return }
                
                switch result {
                case .failure(error: let error) :
                    error.showAlert(vc: self) {
                    }
                default: break
                }
                
                completion()
            }
        }
    }
    
    private func showAlert() {
//        if let favouritePodcast = object as? FavouritePodcast {
//            let name = favouritePodcast.podcast.trackName ?? ""
//            let title = "\(name) podcast is added to playlist"
//            addToast(title: title, (playerIsSHidden ? .bottom : .bottomWithPlayer))
//        }
    }
    
    private func delete(_ object: Any, indexPath: IndexPath?) {
        
        model.remove(object, removeSection: { [weak self] index in
            guard let self = self else { return }
            favouriteTableView.deleteSection(at: index)
            configureScopeBar()
        }, removeItem: { [weak self] indexPath in
            guard let self = self else { return }
            favouriteTableView.deleteItem(at: indexPath)
        })
        
    }
    
    private func insert(_ object: Any, newIndexPath: IndexPath?) {
        
        model.append(object, at: newIndexPath, insertSection: { [weak self] section, index in
            guard let self = self else { return }
            configureScopeBar()
            favouriteTableView.insertSection(at: index)
        }, insertItem: { [weak self] indexPath in
            guard let self = self else { return }
            favouriteTableView.insertCell(at: indexPath)
        })
        
        if let favouritePodcast = object as? FavouritePodcast {
            let name = favouritePodcast.podcast.trackName ?? ""
            let title = "\(name) podcast is added to playlist"
            addToast(title: title, (playerIsSHidden ? .bottom : .bottomWithPlayer))
        }
    }
    
    private func move(_ anObject: Any, indexPath: IndexPath?, newIndexPath: IndexPath?) {
        guard let index = indexPath?.row,
              let newIndex = newIndexPath?.row  else { return }
        model.moveSection(anObject, from: index, to: newIndex) { [weak self] index, newIndex in
            guard let self = self else { return }
            favouriteTableView.moveSection(from: index, to: newIndex)
        }
    }
}

//MARK: - UISearchBarDelegate
extension ListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        model.changeSearchedSection(searchedSection: selectedScope)
        favouriteTableView.reloadTableViewData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        model.changeSearchedSection(searchedSection: .zero)
        favouriteTableView.reloadTableViewData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        model.performSearch(text: searchText)
        favouriteTableView.reloadTableViewData()
    }
}

//MARK: - PlayerEventNotification
extension ListViewController: PlayerDelegate {
    
    func playerDidEndPlay(with track: OutputPlayerProtocol) {
        favouriteTableView.updateTableView(with: track)
    }
    
    func playerStartLoading(with track: OutputPlayerProtocol) {
        favouriteTableView.updateTableView(with: track)
    }
    
    func playerDidEndLoading(with track: OutputPlayerProtocol) {
        favouriteTableView.updateTableView(with: track)
    }
    
    func playerUpdatePlayingInformation(with track: OutputPlayerProtocol) {
        favouriteTableView.updateTableView(with: track)
    }
    
    func playerStateDidChanged(with track: OutputPlayerProtocol) {
        favouriteTableView.updateTableView(with: track)
    }
}

//MARK: - DownloadEventNotifications
extension ListViewController: DownloadServiceDelegate {
    
    func updateDownloadInformation(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        favouriteTableView.updateTableView(with: entity)
    }
    
    func didEndDownloading(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        favouriteTableView.updateTableView(with: entity)
    }
    
    func didPauseDownload(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        favouriteTableView.updateTableView(with: entity)
    }
    
    func didContinueDownload(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        favouriteTableView.updateTableView(with: entity)
    }
    
    func didStartDownload(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        favouriteTableView.updateTableView(with: entity)
    }
    
    func didRemoveEntity(_ downloadService: DownloadServiceInput, entity: DownloadServiceType) {
        favouriteTableView.updateTableView(with: entity)
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension ListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        favouriteTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .delete:
            delete(anObject, indexPath: indexPath)
        case .insert:
            insert(anObject, newIndexPath: newIndexPath)
        case .move:
            move(anObject, indexPath: indexPath, newIndexPath: newIndexPath)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        favouriteTableView.endUpdates()
    }
}

//MARK: - FavouriteTableViewDelegate
extension ListViewController: FavouriteTableViewDelegate {
    
    func favouriteTableView(_ favouriteTableView: FavouriteTableView, didRefreshed refreshControl: UIRefreshControl) {
        refreshTableView {
            refreshControl.endRefreshing()
        }
    }
}

//MARK: - FavouriteTableDataSource
extension ListViewController: FavouriteTableDataSource {
    
    func favouriteTableView(_ favouriteTableView: FavouriteTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(for: favouriteTableView, at: indexPath)
    }
    
    func favouriteTableViewCountOfSections(_ favouriteTableView: FavouriteTableView) -> Int {
        return model.countOfActiveSections
    }
    
    func favouriteTableView(_ favouriteTableView: FavouriteTableView, countOfRowsInSection index: Int) -> Int {
        return model.getCountOfRowsInSection(section: index)
    }
    
    func favouriteTableView(_ favouriteTableView: FavouriteTableView, nameOfSectionFor index: Int) -> String {
        return model.getNameOfSection(for: index)
    }
}

//MARK: - PodcastCellDelegate
extension ListViewController: PodcastCellDelegate {
    
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell) {
        guard let indexPath = favouriteTableView.indexPath(for: podcastCell),
              let favouritePodcast = model.getObjectInSection(for: indexPath) as? FavouritePodcast else { return }
        
        favouriteManager.addOrRemoveFavouritePodcast(entity: favouritePodcast.podcast)
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell) {
        guard let indexPath = favouriteTableView.indexPath(for: podcastCell) else { return }
        guard let entity = model.getObjectInSection(for: indexPath) as? InputDownloadProtocol else { return }
        downloadService.conform(entity: entity)
    }
    
    func podcastCellDidTouchPlayButton(_ podcastCell: PodcastCell) {
        guard let indexPath = favouriteTableView.indexPath(for: podcastCell),
              let favouritePodcast = model.getObjectInSection(for: indexPath) as? FavouritePodcast,
              let favouritePodcasts = model.getObjectsInSections(for: indexPath) as? [FavouritePodcast] else { fatalError() }
        
        player.conform(track: favouritePodcast.podcast, trackList: favouritePodcasts.map { $0.podcast })
    }
    
    func podcastCellDidTouchStopButton(_ podcastCell: PodcastCell) {
        player.playOrPause()
    }
}

//MARK: - AlertSortListViewMyDelegate
extension ListViewController: AlertSortListViewDelegate {
    
}

//MARK: - AlertSortListViewDataSource
extension ListViewController: AlertSortListViewDataSource {
    
}

