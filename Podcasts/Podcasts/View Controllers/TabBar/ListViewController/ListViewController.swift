//
//  PlaylistTableViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit
import CoreData

class ListViewController: UIViewController, IHaveStoryBoardAndViewModel {
    
    typealias ViewModel = ListViewModel
    struct Args {}
    
    func viewModelChanged() {
        updateUI()
    }
    
    private let refreshControl = UIRefreshControl()
    
    private var playerIsSHidden: Bool = true
    
    lazy private var heightTabBarItem = tabBarController?.tabBar.frame.height ?? 0
    
    //MARK: Outlets
    @IBOutlet private weak var favouriteTableView: FavouriteTableView!
    @IBOutlet private weak var bottomTableViewConstraint: NSLayoutConstraint!
    
    private var alertSortListView: AlertSortListView?
    private let container: IContainer
    
    //MARK: init
    required init?(container: IContainer, args: (args: Args, coder: NSCoder)) {
        
        self.container = container
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
            viewModel.removeAll()
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
        configureUI()
        updateUI()
        view.frame.size.width = 400
    }
    
    //MARK: Actions
    private func editButtonDidTouch() {
        guard let alertSortListView = alertSortListView else { fatalError() }
        alertSortListView.showOrHideAlertListView()
    }
    
    func configureUI() {
       configureAlertSortListView()
       favouriteTableView.viewModel = viewModel.getViewModelForTableView()
       navigationItem.hidesSearchBarWhenScrolling = false
   }
    
   func updateUI() {
       configureScopeBar()
       setSearchController()
       configureNavigationItem()
       if viewModel.isLoading {
           view.showActivityIndicator()
       } else {
           view.hideActivityIndicator()
       }
   }
}

//MARK: - Private methods
extension ListViewController {
    
    private func configureScopeBar() {
        let dataSource = viewModel.scopeBar()
        searchController.searchBar.scopeButtonTitles = dataSource?.titles
        if let dataSource = dataSource {
            searchController.searchBar.selectedScopeButtonIndex = dataSource.selectIndex
        }
    }
    
    private func setSearchController() {
        navigationItem.searchController = viewModel.isSearchControllerIsHidden() ? nil : searchController
    }
    
    private func configureNavigationItem() {
        let isHidden = viewModel.isSearchControllerIsHidden()
        
        navigationItem.rightBarButtonItem = isHidden ? nil : removeAllButton
        navigationItem.leftBarButtonItem = editButton
        navigationItem.title = "List"
    }
    
    private func configureAlertSortListView() {
        guard let tabBarController = tabBarController else { fatalError() }
        let args = AlertSortListView.Arguments.init(vc: tabBarController)
        let argsVM = AlertSortListView.ViewModel.Arguments.init()
        let vc: AlertSortListView = container.resolve(args: args, argsVM: argsVM)
       
        tabBarController.view.addSubview(vc)
        alertSortListView = vc
    }
    
    private func showAlert() {

    }
}

//MARK: - UISearchBarDelegate
extension ListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        viewModel.changeSearchedSection(selectedScope: selectedScope)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.cancelSearching()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.performSearch(text: searchText)
    }
}

//MARK: - UIViewControllerTransitioningDelegate
extension ListViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }
}
