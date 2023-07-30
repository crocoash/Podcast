//
//  PlaylistTableViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit
import CoreData

class FavoriteViewController: UIViewController {
    
    private let downloadService: DownloadService
    private let player: Player
    private let firebaseDataBase: FirebaseDatabase
    private let favoriteManager: FavoriteManager
    private let dataStoreManagerInput: DataStoreManagerInput
    
    private var tableViewBottomConstraintConstant = CGFloat(0)
    
    private let refreshControl = UIRefreshControl()
    
    private var searchSection: String? = nil
    
    lazy private var favoriteTableView: FavoriteTableView = {
        
        let tableView = FavoriteTableView(self)
        tableView.frame = view.frame
//        tableView.delegate = self
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.refreshControl = refreshControl
        return tableView
    }()
    
    lazy var favoriteFRC = dataStoreManagerInput.conFigureFRC(for: FavoritePodcast.self, with: [NSSortDescriptor(key: #keyPath(FavoritePodcast.date),ascending: true)])
    
    lazy var likeMomentFRC = dataStoreManagerInput.conFigureFRC(for: LikedMoment.self, with: [NSSortDescriptor(key: #keyPath(LikedMoment.moment), ascending: true)])
    
    lazy var listeningFRC = dataStoreManagerInput.conFigureFRC(for: ListeningPodcast.self, with: [NSSortDescriptor(key: #keyPath(ListeningPodcast.duration),ascending: true)])
    
    lazy private var entities: [[NSManagedObject]] = [likeMomentFRC.fetchedObjects ?? [], favoriteFRC.fetchedObjects ?? [], listeningFRC.fetchedObjects ?? []]
    
    private var filteredEntities: [[NSManagedObject]] {
        return entities.filter { !$0.isEmpty }
    }
    
    //MARK: init
    init(downloadService: DownloadService,
         player: Player,
         addToFavoriteManager: FavoriteManager,
         firebaseDataBase: FirebaseDatabase,
         dataStoreManagerInput: DataStoreManagerInput) {
        
        self.downloadService = downloadService
        self.player = player
        self.favoriteManager = addToFavoriteManager
        self.firebaseDataBase = firebaseDataBase
        self.dataStoreManagerInput = dataStoreManagerInput
        
        super.init(nibName: nil, bundle: nil)
        
        favoriteFRC.delegate = self
        likeMomentFRC.delegate = self
        listeningFRC.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var searchText: String? {
        didSet {
            if let searchText = searchText, searchText != "" {
                let predicate = NSPredicate(format: "podcast.trackName CONTAINS [c] %@", "\(searchText)")
                self.favoriteFRC.fetchRequest.predicate = predicate
                self.likeMomentFRC.fetchRequest.predicate = predicate
                self.listeningFRC.fetchRequest.predicate = predicate
            } else {
                self.favoriteFRC.fetchRequest.predicate = nil
                self.likeMomentFRC.fetchRequest.predicate = nil
                self.listeningFRC.fetchRequest.predicate = nil
            }
            try? favoriteFRC.performFetch()
            try? likeMomentFRC.performFetch()
            try? listeningFRC.performFetch()
        }
    }
    
    //MARK: Variables
    lazy private var searchController: UISearchController = {
        $0.searchBar.placeholder = "Localized.search"
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
        //        playerIsSHidden = !value
    }
    
    func toggleEditing() {
        favoriteTableView.setEditing(!favoriteTableView.isEditing, animated: true)
    }
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = removeAllButton
        navigationItem.leftBarButtonItem = editButton
        navigationItem.title = "Favorite List"
        
        player.addObserverPlayerEventNotification(for: self)
        downloadService.addObserverDownloadEventNotifications(for: self)
        
        view.addSubview(favoriteTableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: Actions
    @objc func tapFavoritePodcastCell(sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? UITableViewCell,
              let indexPath = favoriteTableView.indexPath(for: cell) else { return }
        
        let entity = getObject(for: indexPath)
    }
    
    @objc func refreshTableView() {
        let viewContext = dataStoreManagerInput.viewContext
        
        firebaseDataBase.update(viewContext: viewContext) { [weak self] (result: FavoritePodcast.ResultType) in
            switch result {
            case .failure(error: let error) :
                error.showAlert(vc: self) {
                    self?.refreshControl.endRefreshing()
                    self?.refreshControl.isHidden = true
                }
            case .success(result: _) :
                self?.refreshControl.endRefreshing()
                self?.refreshControl.isHidden = true
                self?.favoriteTableView.reloadData()
            }
        }
    }
}

//MARK: - Private methods
extension FavoriteViewController {
    
    private func getObject(for indexPath: IndexPath) -> NSManagedObject {
        return filteredEntities[indexPath.section][indexPath.row]
    }
    
    private func getObjects(for indexPath: IndexPath) -> [NSManagedObject] {
        return filteredEntities[indexPath.section]
    }
    
    private func removeAllAction() {
        favoriteManager.removeAll()
    }
    
    private var playerIsSHidden: Bool {
        return true
        //            tableViewBottomConstraintConstant = playerIsSHidden ? 0 : 50
        //            tableViewBottomConstraint?.constant = tableViewBottomConstraintConstant
    }
        
    private func configureCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        
        let item = filteredEntities[indexPath.section][indexPath.row]
        
        if let item = item as? FavoritePodcast {
            let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
            
            let isFavorite = favoriteManager.isFavorite(item)
            let isDownloaded = downloadService.isDownloaded(entity: item)
            
            cell.configureCell(self, with: item, isFavorite: isFavorite, isDownloaded: isDownloaded)
            cell.addMyGestureRecognizer(self, type: .tap(), #selector(tapFavoritePodcastCell(sender:)))
            return cell
        } else if let item = item as? LikedMoment {
            let cell = tableView.getCell(cell: LikedPodcastTableViewCell.self, indexPath: indexPath)
            cell.configureCell(with: item.podcast)
            return cell
        } else if let item = item as? ListeningPodcast {
            let cell = tableView.getCell(cell: ListeningPodcastCell.self, indexPath: indexPath)
            cell.configure(with: item)
            return cell
        }
        fatalError()
    }
    
    private func getSection(for index: Int) -> String? {
        filteredEntities[index].first?.entityName
    }
    
    private func getCountOfRowsInSection(section index: Int) -> Int {
        filteredEntities[index].count
    }
}


//MARK: - UISearchResultsUpdating
extension FavoriteViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        //        let searchText = searchController.searchBar.text
        //        if searchText != "" || Section.searchText != nil {
        //            Section.searchText = searchText
        //        }
        //
        favoriteTableView.reloadData()
    }
}

//MARK: - UISearchBarDelegate
extension FavoriteViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //        self.searchSection = Section[selectedScope]
        self.favoriteTableView.reloadData()
    }
}

//MARK: - PlayerEventNotification
extension FavoriteViewController: PlayerEventNotification {
    
    func playerDidEndPlay(with track: OutputPlayerProtocol) {
        favoriteTableView.updateTableView(with: track)
    }
    
    func playerStartLoading(with track: OutputPlayerProtocol) {
        favoriteTableView.updateTableView(with: track)
    }
    
    func playerDidEndLoading(with track: OutputPlayerProtocol) {
        favoriteTableView.updateTableView(with: track)
    }
    
    func playerUpdatePlayingInformation(with track: OutputPlayerProtocol) {
        favoriteTableView.updateTableView(with: track)
    }
    
    func playerStateDidChanged(with track: OutputPlayerProtocol) {
        favoriteTableView.updateTableView(with: track)
    }
}

//MARK: - DownloadEventNotifications
extension FavoriteViewController: DownloadEventNotifications {
    
    func updateDownloadInformation(_ downloadService: DownloadService, entity: DownloadServiceType) {
        favoriteTableView.updateTableView(with: entity)
    }
    
    func didEndDownloading(_ downloadService: DownloadService, entity: DownloadServiceType) {
        favoriteTableView.updateTableView(with: entity)
    }
    
    func didPauseDownload(_ downloadService: DownloadService, entity: DownloadServiceType) {
        favoriteTableView.updateTableView(with: entity)
    }
    
    func didContinueDownload(_ downloadService: DownloadService, entity: DownloadServiceType) {
        favoriteTableView.updateTableView(with: entity)
    }
    
    func didStartDownload(_ downloadService: DownloadService, entity: DownloadServiceType) {
        favoriteTableView.updateTableView(with: entity)
    }
    
    func didRemoveEntity(_ downloadService: DownloadService, entity: DownloadServiceType) {
        favoriteTableView.updateTableView(with: entity)
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension FavoriteViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        favoriteTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .delete:
            guard var indexPath = indexPath else { return }
            
            if anObject is FavoritePodcast {
                if let sec = entities.firstIndex(where: { $0 is [FavoritePodcast] }) {
                    indexPath.section = sec
                }
            } else if anObject is ListeningPodcast {
                if let sec = entities.firstIndex(where: { $0 is [ListeningPodcast] }) {
                    indexPath.section = sec
                }
            } else if anObject is LikedMoment {
                if let sec = entities.firstIndex(where: { $0 is [LikedMoment] }) {
                    indexPath.section = sec
                }
            }
            entities[indexPath.section].remove(at: indexPath.row)
            favoriteTableView.deleteItem(at: indexPath)
            
        case .insert:
            
            guard var newIndexPath = newIndexPath else { return }
            
            if let object = anObject as? FavoritePodcast {
                if let sec = getSection(for: object)  {
                    newIndexPath.section = sec
                    entities[sec].append(object)
                }
            } else if let object = anObject as? ListeningPodcast {
                if let sec = getSection(for: object) {
                    newIndexPath.section = sec
                    entities[sec].append(object)
                }
            } else if let object = anObject as? LikedMoment {
                if let sec = getSection(for: object)  {
                    newIndexPath.section = sec
                    entities[sec].append(object)
                }
            }
            
            let isFirstElementInSection = filteredEntities[newIndexPath.section].count == 1
            let isLastSection = filteredEntities.count == newIndexPath.section + 1
            
            var insertSection = ""
            if isFirstElementInSection, filteredEntities.count != 1 {
                if isLastSection {
                    insertSection = getSection(for: newIndexPath.section - 1) ?? ""
                } else {
                    insertSection = getSection(for: newIndexPath.section + 1) ?? ""
                }
            }
            
            favoriteTableView.insertCell(isLast: isLastSection, insertSection: insertSection, at: newIndexPath, before: indexPath)
            
            //            let favoritePodcast = favoriteFRC.object(at: myNewIndexPath)
            //            let name = favoritePodcast.podcast.trackName ?? ""
            //            let title = "\(name) podcast is added to playlist"
            //            addToast(title: title, (playerIsSHidden ? .bottom : .bottomWithPlayer))
        default : break
        }
    }
    
    private func getSection<T: NSManagedObject>(for object: T) -> Int? {
        for (index,value) in filteredEntities.enumerated() {
            if let entity = value.first as? T {
                return index
            }
        }
        return nil
    }
 
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        favoriteTableView.endUpdates()
    }
}

//MARK: - FavoriteTableDataSource
extension FavoriteViewController: FavoriteTableDataSource {
    
    func favoriteTableView(_ favoriteTableView: FavoriteTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(for: favoriteTableView, at: indexPath)
    }
    
    func favoriteTableViewCountOfSections(_ favoriteTableView: FavoriteTableView) -> Int {
        return filteredEntities.count
    }
    
    func favoriteTableView(_ favoriteTableView: FavoriteTableView, countOfRowsInSection index: Int) -> Int {
        return getCountOfRowsInSection(section: index)
    }
    
    func favoriteTableView(_ favoriteTableView: FavoriteTableView, nameOfSectionFor index: Int) -> String {
        return getSection(for: index) ?? "dwdweqd"
    }
}

//MARK: - PodcastCellDelegate
extension FavoriteViewController: PodcastCellDelegate {
    
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell) {
        guard let indexPath = favoriteTableView.indexPath(for: podcastCell),
              let entity = getObject(for: indexPath) as? (any InputFavoriteType) else { return }
        
        favoriteManager.addOrRemoveFavoritePodcast(entity: entity)
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell) {
        guard let indexPath = favoriteTableView.indexPath(for: podcastCell) else { return }
        guard let entity = getObject(for: indexPath) as? InputDownloadProtocol else { return }
        downloadService.conform(entity: entity)
    }
    
    func podcastCellDidTouchPlayButton(_ podcastCell: PodcastCell) {
        guard let indexPath = favoriteTableView.indexPath(for: podcastCell),
              let entity = getObject(for: indexPath) as? (any InputTrackProtocol),
              let entities = getObjects(for: indexPath) as? [any InputTrackProtocol] else { fatalError() }
        
        player.conform(entity: entity, entities: entities)
    }
    
    func podcastCellDidTouchStopButton(_ podcastCell: PodcastCell) {
        player.playOrPause()
    }
}


//struct Section<T: NSManagedObject> {
//    var entities: [T]
//    var sectionName: String
//    
//    init(entities: [T]) {
//        self.entities = entities
//        self.sectionName = T.entityName
//    }
//}






