//
//  PlaylistTableViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit
import CoreData

protocol FavoritePodcastViewControllerDelegate : AnyObject {
    
    func favoritePodcastTableViewController(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, playlist: [Podcast], podcast: Podcast)
    func favoritePodcastTableViewControllerDidSelectDownLoadImage(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, podcast: Podcast)
    func favoritePodcastTableViewControllerDidSelectStar(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, podcast: Podcast)
    func favoritePodcastTableViewControllerDidSelectCell(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, podcast: Podcast)
//    func favoritePodcastTableViewControllerDidRefreshTableView(_favoritePodcastTableViewController: FavoritePodcastTableViewController)
}

protocol FavoritePodcastViewControllerProtocol {
    var favoritePodcastIsEmpty: Bool { get }
    var favoritePodcastFRC: NSFetchedResultsController<FavoritePodcast> { get }
    func getPodcast(by indexPath: IndexPath) -> Podcast
    func getIndexPath(id: NSNumber?) -> IndexPath?
    func removeAllFavorites()
    func updateFavoritePodcastFromFireBase(completion: ((Result<[FavoritePodcast]>) -> Void)?)
}

class FavoritePodcastTableViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    weak var delegate: FavoritePodcastViewControllerDelegate?
    private var tableViewBottomConstraintConstant = CGFloat(0)
    private let refreshControl = UIRefreshControl()
    private var searchSection: String? = nil
    
    private let emptyTableImageView: UIImageView = {
        $0.image = UIImage(systemName: "folder")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .lightGray
        return $0
    }(UIImageView())
    
    private var diffableDataSource: DataSource!
    
    private var mySnapShot: NSDiffableDataSourceSnapshot<Section, NSManagedObject>! = nil
    
    private var playerIsSHidden = true {
        didSet {
            tableViewBottomConstraintConstant = playerIsSHidden ? 0 : 50
            tableViewBottomConstraint?.constant = tableViewBottomConstraintConstant
        }
    }
    
    class DataSource: UITableViewDiffableDataSource<Section, NSManagedObject> {
        
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return Section[section + 1]
        }
    }
    
    enum Section: CaseIterable, Hashable {
        
        case favourite([FavoritePodcast])
        case liked([LikedMoment])
        
        var nameOfSection: String {
            switch self {
            case .favourite(_) :
                return "Favourite"
            case .liked(_):
                return "Liked"
            }
        }
       
        static subscript (_ int: Int) -> String? {
            switch int {
            case 0 : return nil
            case 1: return allCases[0].nameOfSection
            case 2: return allCases[1].nameOfSection
            default: fatalError()
            }
        }
        
        static var favoriteFRC: NSFetchedResultsController<FavoritePodcast> = FavoritePodcast.fetchResultController()
        static var likeMomentFRC: NSFetchedResultsController<LikedMoment> = LikedMoment.likedMomentFRC()
        
        static var allCases: [FavoritePodcastTableViewController.Section] {
            return [
                .favourite(favoriteFRC.fetchedObjects ?? []),
                .liked(likeMomentFRC.fetchedObjects ?? [])
            ]
        }
        
        static var searchText: String? {
            didSet {
                if let searchText = searchText, searchText != "" {
                    let predicate = NSPredicate(format: "podcast.trackName CONTAINS [c] %@", "\(searchText)")
                    self.favoriteFRC.fetchRequest.predicate = predicate
                    self.likeMomentFRC.fetchRequest.predicate = predicate
                } else {
                    self.favoriteFRC = FavoritePodcast.fetchResultController()
                    self.likeMomentFRC = LikedMoment.likedMomentFRC()
                }
                try? favoriteFRC.performFetch()
                try? likeMomentFRC.performFetch()
            }
        }
    }
    
    lazy private var searchController: UISearchController = {
        $0.searchBar.placeholder = "Localized.search"
        $0.searchBar.scopeButtonTitles = Section.allCases.map { $0.nameOfSection }
        $0.searchBar.scopeButtonTitles?.insert("All", at: .zero)
        
        $0.searchBar.delegate = self
        $0.searchResultsUpdater = self
        $0.definesPresentationContext = true
        if #available(iOS 16.0, *) {
            $0.scopeBarActivation = .onSearchActivation
        }
        return $0
    }(UISearchController(searchResultsController: nil))
    
    lazy private var removeAllButton: UIBarButtonItem = {
        let button =  UIBarButtonItem(title: "Remova All", primaryAction: UIAction {_ in
            self.removeAllAction()
        })
        return button
    }()
    
    lazy private var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(systemItem: .edit, primaryAction: UIAction {_ in
            self.toggleEditing()
        })
        return button
    }()

    
    //MARK: Public Methods
    func updateConstraintForTableView(playerIsPresent value: Bool) {
        playerIsSHidden = !value
    }
    
    /// Download
    func updateDownloadInformation(progress: Float, totalSize: String, podcast: Podcast) {
        guard let favoritePodcast = podcast.getFavoritePodcast,
              let indexPath = favoritePodcast.getIndexPath,
              let podcastCell = tableView?.cellForRow(at: indexPath) as? PodcastCell
        else { return }
        podcastCell.updateDownloadInformation(progress: progress, totalSize: totalSize)
    }
    
    func endDownloading(podcast: Podcast) {
        guard let indexPath = FavoritePodcast.getIndexPath(id: podcast.id) else { return }
        if let cell = tableView.cellForRow(at: indexPath) as? PodcastCell {
            cell.endDownloading()
        }
    }
    
    //MARK: View Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showEmptyImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = removeAllButton
        navigationItem.leftBarButtonItem = editButton
        navigationItem.title = "Favorite List"
        
        Section.favoriteFRC.delegate = self
        Section.likeMomentFRC.delegate = self
      
        tableViewBottomConstraint.constant = tableViewBottomConstraintConstant
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        tableView.invalidateIntrinsicContentSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: Actions
     private func removeAllAction() {
        FavoritePodcast.removeAll()
    }
    
    @objc func tapFavoritePodcastCell(sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? FavoritePodcastTableViewCell,
              let indexPath = tableView.indexPath(for: cell),
              let favoritePodcast = diffableDataSource.itemIdentifier(for: indexPath) as? FavoritePodcast else { return }
       
        let podcast = favoritePodcast.podcast
        self.delegate?.favoritePodcastTableViewControllerDidSelectCell(self, podcast: podcast)
    }
    
    @objc func tapLikedCell(sender: UITapGestureRecognizer) {
        
    }
    
    @objc func refreshTableView() {
        FavoritePodcast.updateFromFireBase { [weak self] result in
            switch result {
            case .failure(error: let error) :
                error.showAlert(vc: self) {
                    self?.refreshControl.endRefreshing()
                    self?.refreshControl.isHidden = true
                }
            case .success(result: _) :
                self?.refreshControl.endRefreshing()
                self?.refreshControl.isHidden = true
            }
        }
    }
    
    func toggleEditing() {
        self.tableView.setEditing(!tableView.isEditing, animated: true)
    }
}

//MARK: - Private methods
extension FavoritePodcastTableViewController {
    
    private func configureUI() {
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.backgroundView = emptyTableImageView
        tableView.rowHeight = 100
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.refreshControl = refreshControl
        configureDataSource()
        reloadData()
    }
    
    private func showEmptyImage() {
        let favoritePodcastsIsEmpty = FavoritePodcast.allObjectsFromCoreData.isEmpty
        tableView.backgroundView?.isHidden = favoritePodcastsIsEmpty
        tableView.backgroundView?.isHidden = !favoritePodcastsIsEmpty
        removeAllButton.isEnabled = !favoritePodcastsIsEmpty
    }
    
    private func getPodcast(_ cell: UITableViewCell) -> Podcast? {
        guard let indexPath = tableView.indexPath(for: cell) else { return nil }
        return FavoritePodcast.getObject(by: indexPath).podcast
    }
    
    private func getPodcast(by indexPath: IndexPath) -> Podcast {
        return FavoritePodcast.getObject(by: indexPath).podcast
    }
    
    private func configureDataSource() {
        self.diffableDataSource = DataSource(tableView: tableView) { [weak self] tableView, indexPath, item in
            
            if let favoritePodcast = item as? FavoritePodcast {
                let cell = tableView.getCell(cell: FavoritePodcastTableViewCell.self, indexPath: indexPath)
                cell.configureCell(with: favoritePodcast.podcast)
                cell.addMyGestureRecognizer(self, type: .tap(), #selector(self?.tapFavoritePodcastCell(sender:)))
                return cell
            }
            
            if let likedMoment = item as? LikedMoment {
                let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
                cell.configureCell(self, with: likedMoment.podcast)
                cell.addMyGestureRecognizer(self, type: .tap(), #selector(self?.tapLikedCell(sender:)))
                return cell
            }
            assert(false,"must be cell for indexPath")
        }
        self.diffableDataSource.defaultRowAnimation = .fade
    }
    
    
    private func reloadData() {
        self.mySnapShot = NSDiffableDataSourceSnapshot<Section, NSManagedObject>()
        
        for section in Section.allCases {
            if searchSection == nil || searchSection == section.nameOfSection {
                switch section {
                case .favourite(let items):
                    mySnapShot.appendSections([section])
                    mySnapShot.appendItems(items)
                case .liked(let items):
                    mySnapShot.appendSections([section])
                    mySnapShot.appendItems(items)
                }
            }
        }

        self.diffableDataSource.apply(mySnapShot, animatingDifferences: true)
    }
}

// MARK: - UITableViewDataSource
//extension FavoritePodcastTableViewController: UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let podcast = getPodcast(by: indexPath)
//            delegate?.favoritePodcastTableViewControllerDidSelectStar(self, podcast: podcast)
//        }
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return FavoritePodcast.fetchResultController.sections?[section].numberOfObjects ?? 0
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return FavoritePodcast.fetchResultController.sections?.count ?? 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
//        let podcast = getPodcast(by: indexPath)
//        cell.configureCell(self,with: podcast)
//        return cell
//    }
//}

//MARK: - PodcastCellDelegate
extension FavoritePodcastTableViewController: PodcastCellDelegate {
    
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell) {
        guard let podcast = getPodcast(podcastCell) else { return }
        delegate?.favoritePodcastTableViewControllerDidSelectStar(self, podcast: podcast)
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell) {
        guard let podcast = getPodcast(podcastCell) else { return }
        delegate?.favoritePodcastTableViewControllerDidSelectDownLoadImage(self, podcast: podcast)
    }
    
    func podcastCellDidTouchPlayButton(_ podcastCell: PodcastCell) {
        
    }
    
    func podcastCellDidTouchStopButton(_ podcastCell: PodcastCell) {
        
    }
}


//MARK: - NSFetchedResultsControllerDelegate
extension FavoritePodcastTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

//        switch type {
//        case .delete :
            
//            let typeOfSection = Item.Category(rawValue: indexPath!.section)
//            let items = mySnapShot.itemIdentifiers(inSection: typeOfSection!)
//            let item = items[indexPath!.row]
            
//            switch item.section {
//            case .favourite:
//                guard let favoritePodcast = item.entity as? FavoritePodcast else { return }
//                self.delegate?.favoritePodcastTableViewControllerDidSelectCell(self, podcast: favoritePodcast.podcast)
//            case .liked:
//                guard let _ = item.entity as? LikedMoment else { return }
//                print("print +++++")
//            }
//            mySnapShot.deleteItems([item])
            
//            guard let indexPath = indexPath else { return }
//            guard let itemIdentifier = diffableDataSource.itemIdentifier(for: indexPath) else { return }
//            snapShot.deleteItems([itemIdentifier])
//            let title = "podcast is removed from playlist"
//            addToast(title: title, (playerIsSHidden ? .bottomWithTabBar : .bottomWithPlayerAndTabBar))
//        case .insert :
//            if let newIndexPath = newIndexPath {
////                tableView.insertRows(at: [newIndexPath], with: .left)
//                snapShot.appendItems(<#T##identifiers: [Item<NSManagedObject>]##[Item<NSManagedObject>]#>)
////                snapShot.appendItems([Item(item: <#T##NSManagedObject#>, section: <#T##Item<NSManagedObject>.Category#>)])
//                let favoritePodcast = FavoritePodcast.fetchResultController.object(at: newIndexPath)
//                let name = favoritePodcast.podcast.trackName ?? ""
//                let title = "\(name) podcast is added to playlist"
//                addToast(title: title, (playerIsSHidden ? .bottom : .bottomWithPlayer))
//            }
//        case .move :
//            if let indexPath = indexPath { 
//                tableView.deleteRows(at: [indexPath], with: .left)
//            }
//            if let newIndexPath = newIndexPath {
//                tableView.insertRows(at: [newIndexPath], with: .left)
//            }
//        case .update :
//            if let indexPath = indexPath {
//                let podcast = getPodcast(by: indexPath)
//                if let cell = tableView.cellForRow(at: indexPath) as? PodcastCell {
//                    cell.configureCell(nil, with: podcast)
//                }
//        }
//        default : break
//        }
//        showEmptyImage()
    }
    
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
//
//        let reloadIdentifiers: [Item] = snapshot.itemIdentifiers.compactMap { itemIdentifier in
//                guard let currentIndex = currentSnapshot.indexOfItem(itemIdentifier), let index = snapshot.indexOfItem(itemIdentifier), index == currentIndex else {
//                    return nil
//                }
//                guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier), existingObject.isUpdated else { return nil }
//                return itemIdentifier
//            }
        
        
//        guard let snapshot1 = snapshot as? NSDiffableDataSourceSnapshot<Item.Category, Item> else { return }
//
//        let itemsIdentifier: [Item] = snapshot1.itemIdentifiers.map {
//            return $0
////            controller.managedObjectContext.existingObject(with: )
//        }
        

          
//        self.diffableDataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Item.Category, Item>, animatingDifferences: true)
//}
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
}

//MARK: - UISearchResultsUpdating
extension FavoritePodcastTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        if searchText != "" || Section.searchText != nil {
            Section.searchText = searchText
            reloadData()
        }
       
    }
}

//MARK: - UISearchBarDelegate
extension FavoritePodcastTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.searchSection = Section[selectedScope]
        self.reloadData()
    }
}
