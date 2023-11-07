//
//  FavouriteTableView.swift
//  Podcasts
//
//  Created by Anton on 24.07.2023.
//

import UIKit
import CoreData

//MARK: - Delegate
@objc protocol FavouriteTableViewDelegate: AnyObject { //
    func favouriteTableView(_ favouriteTableView: FavouriteTableView, didRefreshed refreshControl: UIRefreshControl)
}

class FavouriteTableView: UITableView, IDiffableTableView, IHaveViewModel {
    
    typealias ViewModel = FavouriteTableViewModel
    
    var mySnapShot: SnapShot!
    var diffableDataSource: DiffableDataSource!
    
    func viewModelChanged() {
        
    }
    
    func viewModelChanged(_ viewModel: FavouriteTableViewModel) {
        updateUI()
    }
    
    @IBOutlet weak var myDelegate: FavouriteTableViewDelegate?
    
    private let emptyTableImageView: UIImageView = {
        $0.image = UIImage(systemName: "folder")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .lightGray
        return $0
    }(UIImageView())
    
    //MARK: View Methods
    func reloadDataSource() {
        configureDataSource()
        reloadTableView()
        observeViewModel()
        diffableDataSource.defaultRowAnimation = .fade
        updateUI()
    }
    
    //MARK: init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureTableView()
    }
    
    //MARK: Actions
    @objc func refreshed() {
        guard let refreshControl = refreshControl else { return }
        myDelegate?.favouriteTableView(self, didRefreshed: refreshControl)
    }
    
    func configureDataSource() {
        let titles = viewModel.sections
        diffableDataSource = DataSource(tableView: self, titles: titles, cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
            guard let self = self else { fatalError() }
            return viewModel.getCell(self, for: indexPath)
        })
    }
    
//    override func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
//        let items = indexPaths.compactMap { diffableDataSource.itemIdentifier(for: $0) }
//        mySnapShot.deleteItems(items)
//        diffableDataSource.apply(mySnapShot)
//    }
    
    class DataSource: DiffableDataSource {
        
        private var titles: [Section]
        
        init(tableView: UITableView, titles: [Section], cellProvider: @escaping DiffableDataSource.CellProvider) {
            self.titles = titles
            super.init(tableView: tableView, cellProvider: cellProvider)
        }
        
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return titles[section]
        }
    }
}


//MARK: - Private Methods
extension FavouriteTableView {
    
    private func updateUI() {
        setScrollEnabled()
        showEmptyImage()
    }
    
    private func showEmptyImage() {
        backgroundView?.isHidden = !viewModel.isEmpty
    }
    
    private func configureTableView() {
        backgroundView = emptyTableImageView
        rowHeight = 100
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshed), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    private func setScrollEnabled() {
        var enabled = false
        if viewModel.isEmpty {
            let heightOfCells = (0..<numberOfSections).reduce(into: 0) { $0 += rect(forSection: $1).height + 50 }
            let enabled = heightOfCells > frame.height
        }
        isScrollEnabled = enabled
    }
}
