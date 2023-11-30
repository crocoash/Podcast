//
//  FavouriteTableView.swift
//  Podcasts
//
//  Created by Anton on 24.07.2023.
//

import UIKit
import CoreData

class FavouriteTableView: UITableView, IDiffableTableViewWithModel, IHaveViewModel {
    
    typealias Row = ViewModel.Row
    typealias Section = ViewModel.Section
    typealias ViewModel = FavouriteTableViewModel
    
    var mySnapShot: SnapShot!
    var diffableDataSource: DiffableDataSource!
       
    func viewModelChanged(_ viewModel: FavouriteTableViewModel) {
        configureUI()
    }
    
    func viewModelChanged() {
        updateUI()
    }
    
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
    }
    
    func configureUI() {
        configureTableView()
        observeViewModel()
        reloadDataSource()
        diffableDataSource.defaultRowAnimation = .left
    }
    
    func updateUI() {
        setScrollEnabled()
        showEmptyImage()
    }
    
    //MARK: Actions
    @objc func refreshed() {
        guard let refreshControl = refreshControl else { return }
        viewModel.refresh(refreshControl: refreshControl)
    }
    
    func configureDataSource() {
        let titles = viewModel.sections
        diffableDataSource = DataSource(tableView: self, titles: titles, cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
            guard let self = self else { fatalError() }
            return viewModel.getCell(self, for: indexPath)
        })
    }
    
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
        if !viewModel.isEmpty {
            let heightOfCells = (0..<numberOfSections).reduce(into: 0) { $0 += rect(forSection: $1).height + 50 }
            enabled = heightOfCells > frame.height
        }
        isScrollEnabled = enabled
    }
}
