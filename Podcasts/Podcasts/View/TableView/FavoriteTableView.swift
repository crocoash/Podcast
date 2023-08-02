//
//  FavoriteTableView.swift
//  Podcasts
//
//  Created by Anton on 24.07.2023.
//

import UIKit
import CoreData

//extension FavoriteTableViewProtocol {
//    func getIndexPath(for object: AnyObject) -> IndexPath? {
//        for (indexSection, section) in sections.enumerated() {
//            for (indexRow, item) in section.items.enumerated() {
//                if item === object {
//                    return IndexPath(row: indexRow, section: indexSection)
//                }
//            }
//        }
//        return nil
//    }
//}


//protocol FavoriteTableViewDelegate: AnyObject {
//    
//    func favoriteTableViewDidRefreshed(_ favoriteTableView: FavoriteTableView)
//    func favoriteTableView(_ favoriteTableView: FavoriteTableView, didSelectCellAt indexPath: IndexPath)
//    func favoriteTableView(_ favoriteTableView: FavoriteTableView, didSelectPlayButtonAt indexPath: IndexPath)
//    func favoriteTableView(_ favoriteTableView: FavoriteTableView, didSelectDownloadButtonAt indexPath: IndexPath)
//    func favoriteTableView(_ favoriteTableView: FavoriteTableView, didSelectFavoriteButtonAt indexPath: IndexPath)
//}

protocol FavoriteTableDataSource: AnyObject {
    
    func favoriteTableView(_ favoriteTableView: FavoriteTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func favoriteTableView(_ favoriteTableView: FavoriteTableView, nameOfSectionFor index: Int) -> String
    func favoriteTableViewCountOfSections(_ favoriteTableView: FavoriteTableView) -> Int
    func favoriteTableView(_ favoriteTableView: FavoriteTableView, countOfRowsInSection index: Int) -> Int
}

class FavoriteTableView: UITableView {
    
    typealias SnapShot = NSDiffableDataSourceSnapshot<String, UITableViewCell>
    typealias DiffableDataSource = UITableViewDiffableDataSource<String, UITableViewCell>
    
    typealias InputType = [(section: String, items: [NSManagedObject])]
    
    private let emptyTableImageView: UIImageView = {
        $0.image = UIImage(systemName: "folder")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .lightGray
        return $0
    }(UIImageView())
    
    weak var myDataSource: FavoriteTableDataSource?
    
    private var diffableDataSource: DataSource!
    
    private var mySnapShot: SnapShot! = nil
    
    //MARK: Public Methods
    func insertCell(isLast: Bool, insertSection: String, at indexPath: IndexPath, before oldIndexPath: IndexPath?) {
                
        guard let section = myDataSource?.favoriteTableView(self, nameOfSectionFor: indexPath.section),
              let cell = myDataSource?.favoriteTableView(self, cellForRowAt: indexPath)
        else { return }
        
        var alreadyAdd: Bool = false
        
        if let oldIndexPath = oldIndexPath, let item = diffableDataSource.itemIdentifier(for: oldIndexPath) {
            mySnapShot.insertItems([cell], beforeItem: item)
        } else {
            if mySnapShot.sectionIdentifiers.isEmpty {
                mySnapShot.appendSections([section])
                mySnapShot.appendItems([cell])
            } else {
                /// if section is already create
                for (index, sectionIdentifires) in mySnapShot.sectionIdentifiers.enumerated() {
                    if sectionIdentifires == section {
                        
                        if index == indexPath.section {
                            mySnapShot.appendItems([cell], toSection: section)
                            alreadyAdd = true
                        } else {
                            
                            if let section = myDataSource?.favoriteTableView(self, nameOfSectionFor: indexPath.section) {
                                mySnapShot.appendSections([section])
                                mySnapShot.appendItems([cell])
                                alreadyAdd = true
                            }
                        }
                        break
                    }
                }
                
                if !alreadyAdd {
                    if isLast {
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
    
    private func section(for indexPath: IndexPath) -> String {
        return mySnapShot.sectionIdentifiers[indexPath.section]
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
    
    //MARK: init
    init<T: FavoriteTableDataSource>(_ vc: T, frame: CGRect? = nil) {
        
        self.myDataSource = vc
        
        super.init(frame: frame ?? .zero, style: .plain)
        
        
        configureTableView()
        reloadTableViewData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Public Methods
    func reloadTableViewData() {
        configureDataSource()
        reloadTableView()
    }
    
    func reloadCell(_ cell: UITableViewCell) {
        guard let indexPath = indexPath(for: cell),
              let identifier = diffableDataSource.itemIdentifier(for: indexPath) else { return }
        
        mySnapShot.reloadItems([identifier])
    }
    
    func updateTableView(with type: Any) {
        visibleCells.forEach {
            if let podcastCell = $0 as? PodcastCell {
                podcastCell.update(with: type)
            }
        }
    }
}

//MARK: - Private Methods
extension FavoriteTableView {
    
    private func configureDataSource() {
        
        guard let countOfSection = myDataSource?.favoriteTableViewCountOfSections(self) else { return }
        
        var titles: [String] = []
        
        for index in 0..<countOfSection {
            if let section = myDataSource?.favoriteTableView(self, nameOfSectionFor: index) {
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
        
        let countOfSections = myDataSource.favoriteTableViewCountOfSections(self)
        
        self.mySnapShot = SnapShot()
        
        for indexSection in 0..<countOfSections {
            
            let countOfItems = myDataSource.favoriteTableView(self, countOfRowsInSection: indexSection)
            
            var cells = [UITableViewCell]()
            
            for indexRow in 0..<countOfItems {
                
                let cell = myDataSource.favoriteTableView(self, cellForRowAt: IndexPath(item: indexRow, section: indexSection))
                cells.append(cell)
            }
            
            let section = myDataSource.favoriteTableView(self, nameOfSectionFor: indexSection)
            mySnapShot.appendSections([section])
            mySnapShot.appendItems(cells)
        }
        
        self.diffableDataSource.apply(mySnapShot, animatingDifferences: true)
        showEmptyImage()
    }
    
    private func showEmptyImage() {
        let favoritePodcastsIsEmpty = mySnapShot.itemIdentifiers.count == 0
        
        backgroundView?.isHidden = !favoritePodcastsIsEmpty
    }
    
    private func configureTableView() {
        backgroundView = emptyTableImageView
        rowHeight = 100
        self.refreshControl = refreshControl
    }
}

//MARK: - DataSource
extension FavoriteTableView {
    
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

////MARK: - UITableViewDelegate
//extension FavoriteTableView: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let item = diffableDataSource.itemIdentifier(for: indexPath)
//        switch item {
//        case is PodcastCell: return 100
//        case is LikedPodcastTableViewCell: return 200
//        case is ListeningPodcastCell: return 400
//        default: return 10
//        }
//    }
//}
