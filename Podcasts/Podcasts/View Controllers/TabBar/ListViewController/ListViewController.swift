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

class ListViewController: UIViewController, IHaveViewModel, IHaveStoryBoard {
   
    typealias Args = ListViewControllerDelegate
    typealias ViewModel = ListViewModel
    
    func viewModelChanged() {
        
    }
    
    func viewModelChanged(_ viewModel: ListViewModel) {
        updateUI()
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
    required init?(container: IContainer, args: (args: Args, coder: NSCoder)) {

        self.downloadService = container.resolve()
        self.player = container.resolve()
        self.listDataManager = container.resolve()
        self.firebaseDataBase = container.resolve()
        self.favouriteManager = container.resolve()
        self.dataStoreManager = container.resolve()
        self.listeningManager = container.resolve()
        self.likeManager = container.resolve()

        self.container = container

        self.delegate = args.args

        super.init(coder: args.coder)
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
        observeViewModel()
        configureAlertSortListView()
    }
    
    //MARK: Actions
    @objc private func tapFavouritePodcastCell(sender: UITapGestureRecognizer) {
        
        guard let cell = sender.view as? UITableViewCell,
              let indexPath = favouriteTableView.indexPath(for: cell),
              let favouritePodcast = viewModel.getRow(forIndexPath: indexPath) as? FavouritePodcast else { return }
        delegate?.listViewController(self, didSelect: favouritePodcast.podcast)
    }
    
    @objc private func removeListeningPodcast(sender: UILongPressGestureRecognizer) {
        guard let cell = sender.view as? UITableViewCell,
              let indexPath = favouriteTableView.indexPath(for: cell),
              let listeningPodcast = viewModel.getRow(forIndexPath: indexPath) as? ListeningPodcast else { return }
        
        listeningManager.removeListeningPodcast(listeningPodcast)
    }
}

//MARK: - Private methods
extension ListViewController {
    
    private func editButtonDidTouch() {
        guard let alertSortListView = alertSortListView else { fatalError() }
        alertSortListView.showOrHideAlertListView()
    }
    
    private func removeAllAction() {
        favouriteManager.removeAll()
        listeningManager.removeAll()
        likeManager.removeAll()
    }
    
    private func configureNavigationItem() {
        let isEmpty = viewModel.sectionsIsEmpty && !viewModel.isSearching
        
        navigationItem.rightBarButtonItem = isEmpty ? nil : removeAllButton
        navigationItem.leftBarButtonItem = isEmpty ? nil : editButton
        navigationItem.title = "List"
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setSearchController() {
        navigationItem.searchController = (viewModel.sectionsIsEmpty && !viewModel.isSearching) ? nil : searchController
    }
    
    private func configureScopeBar() {
        if viewModel.sections.count != 0 {
            searchController.searchBar.scopeButtonTitles = viewModel.sections
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
        let vc: AlertSortListView = container.resolveWithModel(args: self)
        tabBarController.view.superview?.addSubview(vc)
        alertSortListView = vc
    }
    
    private func configureCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        
        let item = viewModel.getRow(forIndexPath: indexPath)
        let playlist = viewModel.getPlaylist(for: indexPath.section)
        
        if let podcast = (item as? FavouritePodcast)?.podcast {
            let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
            let args = PodcastCellViewModel.Arguments.init(podcast: podcast, playlist: playlist)
            cell.viewModel = container.resolve(args: args)
            cell.addMyGestureRecognizer(self, type: .tap(), #selector(tapFavouritePodcastCell(sender:)))
            
            return cell
        } else if let likedMoment = item as? LikedMoment {
            let cell = tableView.getCell(cell: LikedPodcastTableViewCell.self, indexPath: indexPath)
            let model = LikedPodcastTableViewCellModel(likedMoment: likedMoment)
            cell.configureCell(with: model)
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
    
    private func observeViewModel() {
        viewModel.removeSection { [weak self] index in
            guard let self = self else { return }
            favouriteTableView.deleteSection(at: index)
            updateUI()
        }
        
        viewModel.removeRow { [weak self] indexPath in
            guard let self = self else { return }
            favouriteTableView.deleteItem(at: indexPath)
        }
        
        viewModel.insertRow { [weak self] item, indexPath in
            guard let self = self else { return }
            favouriteTableView.insertCell(at: indexPath)
            
            if let favouritePodcast = item as? FavouritePodcast {
                let name = favouritePodcast.podcast.trackName ?? ""
                let title = "\(name) podcast is added to playlist"
                addToast(title: title, (playerIsSHidden ? .bottom : .bottomWithPlayer))
            }
        }
        
        viewModel.insertSection { [weak self] section, index in
            guard let self = self else { return }
            favouriteTableView.insertSection(at: index)
            updateUI()
        }
        
        viewModel.moveSection { [weak self] index, newIndex in
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
        viewModel.performSearch(text: searchText)
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
        return viewModel.numbersOfSections
    }
    
    func favouriteTableView(_ favouriteTableView: FavouriteTableView, countOfRowsInSection index: Int) -> Int {
        return viewModel.numbersOfRowsInSection(section: index)
    }
    
    func favouriteTableView(_ favouriteTableView: FavouriteTableView, nameOfSectionFor index: Int) -> String {
        return viewModel.getInputSection(sectionIndex: index)
    }
}

