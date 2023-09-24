//
//  FavouriteTableView.swift
//  Podcasts
//
//  Created by Anton on 24.07.2023.
//

import UIKit
import CoreData

//MARK: - Delegate
@objc protocol FavouriteTableViewDelegate: AnyObject {
    
    func favouriteTableView(_ favouriteTableView: FavouriteTableView, didRefreshed refreshControl: UIRefreshControl)
}

//MARK: - DataSource
@objc protocol FavouriteTableDataSource: AnyObject {
    
    func favouriteTableView               (_ favouriteTableView: FavouriteTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func favouriteTableView               (_ favouriteTableView: FavouriteTableView, nameOfSectionFor index: Int)       -> String
    func favouriteTableViewCountOfSections(_ favouriteTableView: FavouriteTableView)                                    -> Int
    func favouriteTableView               (_ favouriteTableView: FavouriteTableView, countOfRowsInSection index: Int)   -> Int
}


class FavouriteTableView: UITableView, IDiffableTableView {
    
    typealias Row = UITableViewCell
    typealias Section = String
    
    var mySnapShot: SnapShot!
    var diffableDataSource: DataSource!
    
    private let emptyTableImageView: UIImageView = {
        $0.image = UIImage(systemName: "folder")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .lightGray
        return $0
    }(UIImageView())

    @IBOutlet weak var myDataSource: FavouriteTableDataSource? {
        didSet { reloadTableViewData() }
    }
    
    @IBOutlet weak var myDelegate: FavouriteTableViewDelegate?
    
    override func reloadData() {
        super.reloadData()
        diffableDataSource.updateTittles(titles: configureTitles())
        diffableDataSource.apply(mySnapShot)
        showEmptyImage()
        setScrollEnabled()
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
    
    //MARK: Public Methods
    func reloadTableViewData() {
        configureDataSource()
        reloadTableView()
    }
}

extension FavouriteTableView {
    
    func cellForRowAt(indexPath: IndexPath) -> UITableViewCell {
        guard let myDataSource = myDataSource else { fatalError() }
        return myDataSource.favouriteTableView(self, cellForRowAt: indexPath)
    }
    
    func sectionFor(index: Int) -> String {
        guard let myDataSource = myDataSource else { fatalError() }
        return myDataSource.favouriteTableView(self, nameOfSectionFor: index)
    }
    
    func countOfSections() -> Int {
        guard let myDataSource = myDataSource else { fatalError() }
        return myDataSource.favouriteTableViewCountOfSections(self)
    }
    
    func countOfRowsInSection(index: Int) -> Int {
        guard let myDataSource = myDataSource else { fatalError() }
        return myDataSource.favouriteTableView(self, countOfRowsInSection: index)
    }
}

//MARK: - Private Methods
extension FavouriteTableView {
    
    private func configureDataSource() {
        
        let titles = configureTitles()
        
        self.diffableDataSource = DataSource(tableView: self, titles: titles) { tableView, indexPath, cell in
            return cell
        }
        
        self.diffableDataSource.defaultRowAnimation = .fade
    }
    
    private func showEmptyImage() {
        let favouritePodcastsIsEmpty = mySnapShot.itemIdentifiers.count == 0
        
        backgroundView?.isHidden = !favouritePodcastsIsEmpty
    }
    
    private func configureTableView() {
        backgroundView = emptyTableImageView
        rowHeight = 100
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshed), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    private func setScrollEnabled() {
        let heightOfCells = (0..<numberOfSections).reduce(into: 0) { $0 += rect(forSection: $1).height + 50 }
        isScrollEnabled = heightOfCells > frame.height
    }
    
    private func configureTitles() -> [String] {
        guard let countOfSection = myDataSource?.favouriteTableViewCountOfSections(self) else { return [] }
        var titles: [String] = []
        for index in 0..<countOfSection {
            if let section: Section = myDataSource?.favouriteTableView(self, nameOfSectionFor: index) {
                titles.append(section)
            }
        }
        return titles
    }
}

//MARK: - DataSource
extension FavouriteTableView {
    
    class DataSource: UITableViewDiffableDataSource<Section, Row> {
        
        private var titles: [String]
        
        func updateTittles(titles: [String]) {
            self.titles = titles
        }
        
        init(tableView: UITableView, titles: [String], cellProvider: @escaping DiffableDataSource.CellProvider) {
            self.titles = titles
            super.init(tableView: tableView, cellProvider: cellProvider)
        }
        
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return titles[section]
        }
    }
}
