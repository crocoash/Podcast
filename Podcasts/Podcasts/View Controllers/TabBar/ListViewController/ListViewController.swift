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
    
    typealias Args = Input
    typealias ViewModel = ListViewModel
    
    struct Input {
        var delegate: ListViewControllerDelegate
    }
    
    func viewModelChanged(_ viewModel: ListViewModel) {
        updateUI()
    }
    
    //MARK: services
    private let favouriteManager: FavouriteManager
    private let dataStoreManager: DataStoreManager
    private let listeningManager: ListeningManager
    private let likeManager:      LikeManager
    
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
        self.favouriteManager = container.resolve()
        self.dataStoreManager = container.resolve()
        self.listeningManager = container.resolve()
        self.likeManager = container.resolve()
        
        self.container = container
        self.delegate = args.args.delegate
        super.init(coder: args.coder)
        
        self.viewModel = container.resolve()
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
        configureAlertSortListView()
        favouriteTableView.viewModel = viewModel.favouriteTableViewVM
        favouriteTableView.reloadDataSource()
        updateUI()
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
        let isEmpty = viewModel.favouriteTableViewVM.isEmpty && !viewModel.favouriteTableViewVM.isSearching
        
        navigationItem.rightBarButtonItem = isEmpty ? nil : removeAllButton
        navigationItem.leftBarButtonItem = editButton
        navigationItem.title = "List"
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setSearchController() {
        navigationItem.searchController = (viewModel.favouriteTableViewVM.isEmpty && !viewModel.favouriteTableViewVM.isSearching) ? nil : searchController
    }
    
    private func configureScopeBar() {
        guard viewModel.favouriteTableViewVM.searchedSectionData == nil else { return }
        if !viewModel.favouriteTableViewVM.isEmpty {
            searchController.searchBar.scopeButtonTitles = viewModel.favouriteTableViewVM.sections
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
        let args = AlertSortListView.Arguments.init(vc: tabBarController)
        let vc: AlertSortListView = container.resolve(args: args)
        vc.viewModel = container.resolve(args: ())
        tabBarController.view.superview?.addSubview(vc)
        alertSortListView = vc
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
}

//MARK: - UISearchBarDelegate
extension ListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        viewModel.favouriteTableViewVM.changeSearchedSection(searchedSection: selectedScope == 0 ? nil : selectedScope - 1)
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

