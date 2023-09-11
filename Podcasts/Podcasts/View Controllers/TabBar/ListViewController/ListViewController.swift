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

class ListViewController: UIViewController, IHaveViewModel, IPerRequest {
    
    typealias Arguments = ListViewControllerDelegate
    typealias ViewModel = ListViewModel
    
    func viewModelChanged() {
        
    }
    
    func viewModelChanged(_ viewModel: ListViewModel) {
        
    }
    
    //MARK: services
    private var downloadService:  DownloadService
    private var player:           Player
    private let firebaseDataBase: FirebaseDatabase
    private let favouriteManager: FavouriteManager
    private let dataStoreManager: DataStoreManager
    private let listeningManager: ListeningManager
    private let likeManager:      LikeManager
    private var listDataManager: ListDataManager
    
   weak var delegate: ListViewControllerDelegate?
    
    private let refreshControl = UIRefreshControl()
    private var alertTopConstraint: NSLayoutConstraint?
    
    private var playerIsSHidden: Bool = true
    
    lazy private var heightTabBarItem = tabBarController?.tabBar.frame.height ?? 0
    
    //MARK: Outlets
   @IBOutlet private weak var listView: ListView!

    @IBOutlet private weak var favouriteTableView: FavouriteTableView!
    @IBOutlet private weak var bottomTableViewConstraint: NSLayoutConstraint!
    
    private var alertSortListView: AlertSortListView?
    private let container: IContainer
    
    //MARK: init
    required init(container: IContainer, args: Arguments) {
        self.downloadService = container.resolve()
        self.player = container.resolve()
        self.firebaseDataBase = container.resolve()
        self.favouriteManager = container.resolve()
        self.dataStoreManager = container.resolve()
        self.listeningManager = container.resolve()
        self.likeManager = container.resolve()
        self.listDataManager = container.resolve()
        self.container = container
        
        self.delegate = args
        
        super.init(nibName: Self.identifier, bundle: nil)
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
        
        updateUI()
        configureAlertSortListView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK: Actions
    @objc private func tapFavouritePodcastCell(sender: UITapGestureRecognizer) {
        
        guard let cell = sender.view as? UITableViewCell,
              let indexPath = favouriteTableView.indexPath(for: cell),
              let favouritePodcast = viewModel.getObjectInSection(for: indexPath) as? FavouritePodcast else { return }
        delegate?.listViewController(self, didSelect: favouritePodcast.podcast)
    }
    
    @objc private func removeListeningPodcast(sender: UILongPressGestureRecognizer) {
        guard let cell = sender.view as? UITableViewCell,
              let indexPath = favouriteTableView.indexPath(for: cell),
              let listeningPodcast = viewModel.getObjectInSection(for: indexPath) as? ListeningPodcast else { return }
        
        listeningManager.removeListeningPodcast(listeningPodcast)
    }
    
    private func editButtonDidTouch() {
        guard let alertSortListView = alertSortListView else { fatalError() }
        alertSortListView.showOrHideAlertListView()
    }
    
    private func removeAllAction() {
        favouriteManager.removeAll()
        listeningManager.removeAll()
        likeManager.removeAll()
    }
}

//MARK: - Private methods
extension ListViewController {
    
    private func configureNavigationItem() {
        let value = viewModel.sectionsIsEmpty && viewModel.isSearchedText
        
        navigationItem.rightBarButtonItem = value ? nil : removeAllButton
        navigationItem.leftBarButtonItem = value ? nil : editButton
        navigationItem.title = "List"
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setSearchController() {
        navigationItem.searchController = (viewModel.sectionsIsEmpty && !viewModel.isSearchedText) ? nil : searchController
    }
    
    private func configureScopeBar() {
        if viewModel.nameForScopeBar.count != 0 {
            searchController.searchBar.scopeButtonTitles = viewModel.nameForScopeBar
            searchController.searchBar.scopeButtonTitles?.insert("All", at: .zero)
        } else {
            searchController.searchBar.scopeButtonTitles = nil
        }
    }
    
    private func updateUI() {
        configureScopeBar()
        setSearchController()
        configureNavigationItem()
    }
    
    private func configureAlertSortListView() {
        guard let tabBarController = tabBarController else { fatalError() }
        let vc: AlertSortListView = container.resolve(args: self)
        tabBarController.view.superview?.addSubview(vc)
        alertSortListView = vc
    }
    
    private func configureCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        
        let item = viewModel.getObjectInSection(for: indexPath)
        
        if let podcast = (item as? FavouritePodcast)?.podcast {
            let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
            
            let isFavourite = true
            let isDownloaded = downloadService.isDownloaded(entity: podcast)
//            cell.viewModel = PodcastCellViewModel(podcast: podcast)
            cell.configureCell(self, with: podcast)
            cell.addMyGestureRecognizer(self, type: .tap(), #selector(tapFavouritePodcastCell(sender:)))
            return cell
        } else if let item = item as? LikedMoment {
            let cell = tableView.getCell(cell: LikedPodcastTableViewCell.self, indexPath: indexPath)
//            cell.configureCell(with: item.podcast)
        
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
        let _ = dataStoreManager.viewContext
        
//        firebaseDataBase.update(viewContext: viewContext) { [weak self] (result: FavouritePodcast.ResultType) in
//            guard let self = self else { return }
//
//            switch result {
//            case .failure(error: let error) :
//                error.showAlert(vc: self)
//            default: break
//            }
//
//            firebaseDataBase.update(viewContext: viewContext) { [weak self] (result: ListeningPodcast.ResultType) in
//
//                guard let self = self else { return }
//
//                switch result {
//                case .failure(error: let error) :
//                    error.showAlert(vc: self) {
//                    }
//                default: break
//                }
//
//                completion()
//            }
//        }
    }
    
    private func showAlert() {
//        if let favouritePodcast = object as? FavouritePodcast {
//            let name = favouritePodcast.podcast.trackName ?? ""
//            let title = "\(name) podcast is added to playlist"
//            addToast(title: title, (playerIsSHidden ? .bottom : .bottomWithPlayer))
//        }
    }
    
    private func delete(_ object: Any, indexPath: IndexPath?) {
        
        viewModel.remove(object, removeSection: { [weak self] index in
            guard let self = self else { return }
            favouriteTableView.deleteSection(at: index)
            updateUI()
        }, removeItem: { [weak self] indexPath in
            guard let self = self else { return }
            favouriteTableView.deleteItem(at: indexPath)
        })
        
    }
    
    private func insert(_ object: Any, newIndexPath: IndexPath?) {
        
        viewModel.append(object, at: newIndexPath, insertSection: { [weak self] section, index in
            guard let self = self else { return }
            updateUI()
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
        
        viewModel.moveSection(anObject, from: index, to: newIndex) { [weak self] index, newIndex in
            guard let self = self else { return }
            favouriteTableView.moveSection(from: index, to: newIndex)
            updateUI()
        }
    }
}

//MARK: - UISearchBarDelegate
extension ListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        viewModel.changeSearchedSection(searchedSection: selectedScope == 0 ? nil : selectedScope - 1)
        favouriteTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar(searchBar, textDidChange: "")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.performSearch (text: searchText,
                             removeSection: { index in
            favouriteTableView.deleteSection(at: index)
            
        }, removeItem: { indexPath in
            favouriteTableView.deleteItem(at: indexPath)
        }, insertSection: { section, index in
            favouriteTableView.insertSection(at: index)
        }, insertItem: { indexPath in
            favouriteTableView.insertCell(at: indexPath)
        })
        
        updateUI()
        favouriteTableView.reloadData()
    }
}


//MARK: - DownloadEventNotifications


//MARK: - NSFetchedResultsControllerDelegate
extension ListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        favo/uriteTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .delete:
            delete(anObject, indexPath: indexPath)
        case .insert:
            insert(anObject, newIndexPath: newIndexPath)
        case .move:
            move(anObject, indexPath: indexPath, newIndexPath: newIndexPath)
        case .update:
            viewModel.update(with: anObject) { indexPaths in
//                todo
            }
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        favouriteTableView.endUpdates()
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
        return viewModel.countOfSections
    }
    
    func favouriteTableView(_ favouriteTableView: FavouriteTableView, countOfRowsInSection index: Int) -> Int {
        return viewModel.getCountOfRowsInSection(section: index)
    }
    
    func favouriteTableView(_ favouriteTableView: FavouriteTableView, nameOfSectionFor index: Int) -> String {
        return viewModel.getNameOfSection(for: index)
    }
}

//MARK: - PodcastCellDelegate
extension ListViewController: PodcastCellDelegate {
    
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell) {
        guard let indexPath = favouriteTableView.indexPath(for: podcastCell),
              let favouritePodcast = viewModel.getObjectInSection(for: indexPath) as? FavouritePodcast else { return }
        
        favouriteManager.removeFavouritePodcast(entity: favouritePodcast)
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell) {
        guard let indexPath = favouriteTableView.indexPath(for: podcastCell) else { return }
        guard let entity = viewModel.getObjectInSection(for: indexPath) as? DownloadProtocol else { return }
//        downloadService.conform(entity: entity)
    }
    
    func podcastCellDidTouchPlayButton(_ podcastCell: PodcastCell) {
        guard let indexPath = favouriteTableView.indexPath(for: podcastCell),
              let favouritePodcast = viewModel.getObjectInSection(for: indexPath) as? FavouritePodcast,
              let favouritePodcasts = viewModel.getObjectsInSections(for: indexPath.section) as? [FavouritePodcast] else { fatalError() }
        
        player.conform(track: favouritePodcast.podcast, trackList: favouritePodcasts.map { $0.podcast })
    }
    
    func podcastCellDidTouchStopButton(_ podcastCell: PodcastCell) {
        player.playOrPause()
    }
}

