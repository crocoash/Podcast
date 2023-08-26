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
//    func favouriteTableView(_ favouriteTableView: FavouriteTableView, didSelectCellAt indexPath: IndexPath)
//    func favouriteTableView(_ favouriteTableView: FavouriteTableView, didSelectPlayButtonAt indexPath: IndexPath)
//    func favouriteTableView(_ favouriteTableView: FavouriteTableView, didSelectDownloadButtonAt indexPath: IndexPath)
//    func favouriteTableView(_ favouriteTableView: FavouriteTableView, didSelectFavouriteButtonAt indexPath: IndexPath)
}

//MARK: - DataSource
@objc protocol FavouriteTableDataSource: AnyObject {
    
    func favouriteTableView(_ favouriteTableView: FavouriteTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func favouriteTableView(_ favouriteTableView: FavouriteTableView, nameOfSectionFor index: Int) -> String
    func favouriteTableViewCountOfSections(_ favouriteTableView: FavouriteTableView) -> Int
    func favouriteTableView(_ favouriteTableView: FavouriteTableView, countOfRowsInSection index: Int) -> Int
}

class FavouriteTableView: UITableView {
    
    typealias SnapShot = NSDiffableDataSourceSnapshot<String, UITableViewCell>
    typealias DiffableDataSource = UITableViewDiffableDataSource<String, UITableViewCell>
    
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
    
    private var diffableDataSource: DataSource!
    private var mySnapShot: SnapShot! = nil
    
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
    
    func updateTableView(with type: Any) {
        if !isTracking {
            visibleCells.forEach {
                if let podcastCell = $0 as? PodcastCell {
                    podcastCell.update(with: type)
                }
                
                if let listeningPodcast = $0 as? ListeningPodcastCell {
                    listeningPodcast.update(with: type)
                }
                
//                if let likedPodcastTableViewCell = $0 as? LikedPodcastTableViewCell {
//                    likedPodcastTableViewCell.update(with: type)
//                }
            }
        }
    }
    
    func deleteSection(at index: Int) {
        guard let identifier = myDataSource?.favouriteTableView(self, nameOfSectionFor: index) else { return }
        mySnapShot.deleteSections([identifier])
        diffableDataSource.apply(mySnapShot)
    }

    func moveSection(from oldIndex: Int, to newIndex: Int) {
        let countOfSections = mySnapShot.sectionIdentifiers.count - 1
        let isFirstSection = newIndex == 0
        let isLastSection = newIndex == countOfSections
        
        let section = mySnapShot.sectionIdentifiers[oldIndex]
        
        if isFirstSection {
            let firstSection = mySnapShot.sectionIdentifiers[0]
            mySnapShot.moveSection(section, beforeSection: firstSection)
        } else if isLastSection {
            let lastSection = mySnapShot.sectionIdentifiers[countOfSections]
            mySnapShot.moveSection(section, afterSection: lastSection)
        } else {
            let beforeSection = mySnapShot.sectionIdentifiers[newIndex]
            mySnapShot.moveSection(section, beforeSection: beforeSection)
        }
        
        diffableDataSource.apply(mySnapShot)
    }
    
    func deleteItem(at indexPath: IndexPath) {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else { return }

        let section = mySnapShot.sectionIdentifiers[indexPath.section]
        
        mySnapShot.deleteItems([item])
        if mySnapShot.numberOfItems(inSection: section) == 0 {
            mySnapShot.deleteSections([section])
        }
        showEmptyImage()
        diffableDataSource.apply(mySnapShot)
    }
    
    func insertCell(isLastSection: Bool, insertSection: String, at indexPath: IndexPath, before oldIndexPath: IndexPath?) {
                
        guard let section = myDataSource?.favouriteTableView(self, nameOfSectionFor: indexPath.section),
              let cell = myDataSource?.favouriteTableView(self, cellForRowAt: indexPath)
        else { return }
        
        if let oldIndexPath = oldIndexPath, let item = diffableDataSource.itemIdentifier(for: oldIndexPath) {
            mySnapShot.insertItems([cell], beforeItem: item)
        } else {
            if mySnapShot.sectionIdentifiers.isEmpty {
                mySnapShot.appendSections([section])
                mySnapShot.appendItems([cell])
            } else {
                
                var alreadyAdd: Bool = false
                /// if section is already create
                for (index, sectionIdentifires) in mySnapShot.sectionIdentifiers.enumerated() {
                    if sectionIdentifires == section {
                        
                        if index == indexPath.section {
                            mySnapShot.appendItems([cell], toSection: section)
                            alreadyAdd = true
                        } else {
                            
                            if let section = myDataSource?.favouriteTableView(self, nameOfSectionFor: indexPath.section) {
                                mySnapShot.appendSections([section])
                                mySnapShot.appendItems([cell])
                                alreadyAdd = true
                            }
                        }
                        break
                    }
                }
                
                if !alreadyAdd {
                    if isLastSection {
                        mySnapShot.insertSections([section], afterSection: insertSection)
                    } else {
                        mySnapShot.insertSections([section], beforeSection: insertSection)
                    }
                    mySnapShot.appendItems([cell], toSection: section)
                }
            }
        }
        
        configureDataSource()
        diffableDataSource.apply(mySnapShot)
        showEmptyImage()
    }
}

//MARK: - Private Methods
extension FavouriteTableView {
    
    private func configureDataSource() {
        
        guard let countOfSection = myDataSource?.favouriteTableViewCountOfSections(self) else { return }
        
        var titles: [String] = []
        
        for index in 0..<countOfSection {
            if let section = myDataSource?.favouriteTableView(self, nameOfSectionFor: index) {
                titles.append(section)
            }
        }
        
        self.diffableDataSource = DataSource(tableView: self, titles: titles) { tableView, indexPath, cell in
            return cell
        }
        
        self.diffableDataSource.defaultRowAnimation = .fade
    }
    
    private func reloadTableView() {
        
        guard let myDataSource = myDataSource else { return }
        
        let countOfSections = myDataSource.favouriteTableViewCountOfSections(self)
        
        self.mySnapShot = SnapShot()
        
        for indexSection in 0..<countOfSections {
            
            let countOfItems = myDataSource.favouriteTableView(self, countOfRowsInSection: indexSection)
            
            var cells = [UITableViewCell]()
            
            for indexRow in 0..<countOfItems {
                
                let cell = myDataSource.favouriteTableView(self, cellForRowAt: IndexPath(item: indexRow, section: indexSection))
                cells.append(cell)
            }
            
            let section = myDataSource.favouriteTableView(self, nameOfSectionFor: indexSection)
            mySnapShot.appendSections([section])
            mySnapShot.appendItems(cells)
        }
        
        self.diffableDataSource.apply(mySnapShot, animatingDifferences: true)
        showEmptyImage()
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
}

//MARK: - DataSource
extension FavouriteTableView {
    
    class DataSource: DiffableDataSource {
        
        private var titles: [String]
        
        init(tableView: UITableView, titles: [String], cellProvider: @escaping DiffableDataSource.CellProvider) {
            self.titles = titles
            super.init(tableView: tableView, cellProvider: cellProvider)
        }
        
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return titles[section]
        }
    }
}
