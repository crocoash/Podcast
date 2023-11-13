//
//  FavouriteViewModel.swift
//  Podcasts
//
//  Created by Anton on 25.09.2023.
//

import UIKit
import CoreData


class FavouriteTableViewModel: NSObject, IPerRequest, INotifyOnChanged, ITableViewModel, IViewModelDinamicUpdating, ITableViewSearched {
    
   
    typealias Arguments = Void

    var searchedSectionData: SectionData?
    var searchedText: String?
    var isSearching: Bool = false
    
    var dataSourceForView: [SectionData] = [] {
        didSet {
            changed.raise()
        }
    }
    var dataSourceAll: [SectionData] = []
    
    let container: IContainer
    let listeningManager: ListeningManager
    let dataStoreManager: DataStoreManager
    
    var test: Bool = false
    var insertSectionOnView: ((Section, Int) -> ())     = { _, _ in }
    var insertItemOnView:    ((Row, IndexPath) -> ())   = { _, _ in }
    var removeRowOnView:     ((IndexPath) -> ())        = {    _ in }
    var removeSectionOnView: ((Int) -> ())              = {    _ in }
    var moveSectionOnView:   ((Int, Int) -> ())         = { _, _ in }
    var reloadSection:       ((Int) -> ())              = { _    in }
    
    lazy private var favouriteFRC = dataStoreManager.conFigureFRC(for: FavouritePodcast.self)
    lazy private var likeMomentFRC = dataStoreManager.conFigureFRC(for: LikedMoment.self)
    lazy private var listeningFRC = dataStoreManager.conFigureFRC(for: ListeningPodcast.self)
    
    lazy private(set) var listSectionFRC = dataStoreManager.conFigureFRC(for: ListSection.self,
                                                                         with: [NSSortDescriptor(key: #keyPath(ListSection.sequenceNumber), ascending: true)])
    
    //MARK: init
    required init?(container: IContainer, args: Arguments) {
        self.container = container
        self.listeningManager = container.resolve()
        self.dataStoreManager = container.resolve()
        
        super.init()

        favouriteFRC.delegate = self
        likeMomentFRC.delegate = self
        listeningFRC.delegate = self
        listSectionFRC.delegate = self
        
        configureDataSource()
    }
    
    @objc private func removeListeningPodcast(sender: MyLongPressGestureRecognizer) {
        guard let indexPath = sender.info as? IndexPath,
              let listeningPodcast = getRowForView(forIndexPath: indexPath) as? ListeningPodcast else { return }
        listeningManager.removeListeningPodcast(listeningPodcast)
    }
    
    
    @objc private func tapFavouritePodcastCell(sender: MyTapGestureRecognizer) {
        guard let indexPath = sender.info as? IndexPath else { return }
//        listViewController(self, didSelect: favouritePodcast.podcast)
    }
    
    func performSearch(_ text: String?) {
        guard searchedText != text else { return }
        searchedText = text ?? ""
        
        if let searchText = text, searchText != "" {
            let predicate = NSPredicate(format: "podcast.trackName CONTAINS [c] %@", "\(searchText)")
            favouriteFRC.fetchRequest.predicate = predicate
            likeMomentFRC.fetchRequest.predicate = predicate
            listeningFRC.fetchRequest.predicate = predicate
        } else {
            favouriteFRC.fetchRequest.predicate = nil
            likeMomentFRC.fetchRequest.predicate = nil
            listeningFRC.fetchRequest.predicate = nil
        }
        
        do {
            try favouriteFRC.performFetch()
            try likeMomentFRC.performFetch()
            try listeningFRC.performFetch()
        } catch {
            print(error)
        }
        
         configureDataSource()
    }
    
    func getCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let row = getRowForView(forIndexPath: indexPath)
        let rows = getRowsForView(atSection: indexPath.section)
        
        switch (row, rows) {
        case (let favouritePodcast as FavouritePodcast, let playlist as [FavouritePodcast]) :
            let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
            let playlist = playlist.map { $0.podcast }
            cell.addMyGestureRecognizer(self, type: .tap(), #selector(tapFavouritePodcastCell(sender:)), info: indexPath)
            let args = PodcastCell.ViewModel.Arguments(podcast: favouritePodcast.podcast, playlist: playlist)
            cell.viewModel = container.resolve(args: args)
            return cell
        case (let likedMoment as LikedMoment, let playlist as [LikedMoment]) :
            let cell = tableView.getCell(cell: LikedPodcastTableViewCell.self, indexPath: indexPath)
            let playlist = playlist.map { $0.podcast }
            let model = LikedPodcastTableViewCellModel(likedMoment: likedMoment)
            cell.configureCell(with: model)
            return cell
        case (let listeningPodcast as ListeningPodcast, let playlist as [ListeningPodcast]) :
            let cell = tableView.getCell(cell: ListeningPodcastCell.self, indexPath: indexPath)
            let playlist = playlist.map { $0.podcast }
            let model = ListeningPodcastCellModel(listeningPodcast)
            cell.configure(with: model)
            return cell
        default:
            fatalError()
        }
    }
}

//MARK: - Private Methods

extension FavouriteTableViewModel {
    
    private func update(with object: Any, reloadIndexPath: ([IndexPath]) -> ()) {
       if let podcast = (object as? ListeningPodcast)?.podcast {
          var indexPath: [IndexPath] = []
          dataSourceForView.enumerated { indexSection, section in
             section.rows.enumerated { indexRow, row in
                switch row {
                case let favoritePodcast as FavouritePodcast:
                   if favoritePodcast.podcast.trackId == podcast.trackId {
                      indexPath.append(IndexPath(row: indexRow, section: indexSection))
                   }
                case let listening as ListeningPodcast:
                   if listening.podcast.trackId == podcast.trackId {
                      indexPath.append(IndexPath(row: indexRow, section: indexSection))
                   }
                case let likedMoment as LikedMoment:
                   if likedMoment.podcast.trackId == podcast.trackId {
                      indexPath.append(IndexPath(row: indexRow, section: indexSection))
                   }
                default:
                   break
                }
             }
          }
          reloadIndexPath(indexPath)
       }
    }
    
    private func getSectionData(forListSection listSection: ListSection) -> SectionData? {
       dataSourceAll.first { $0.section == listSection.nameOfSection }
    }
    
    func getIndexSection(forRow row: Row) -> Int? {
     
       for (indexSection, sectionData) in dataSourceAll.enumerated() {
          if row.entityName == sectionData.nameOfEntity {
            return indexSection
          }
       }
       return nil
    }
    
    func configureDataSource() {
       var sectionData = listSectionFRC.fetchedObjects?.map {
          let entities = getRowsFor(entityName: $0.nameOfEntity)
          return SectionData(listSection: $0, rows: entities)
       }
       sectionData?.sort { $0.sequenceNumber < $1.sequenceNumber }
        update(by: sectionData ?? [])
    }
    
    private func getRowsFor(entityName: String) -> [NSManagedObject] {
        switch entityName {
        case FavouritePodcast.entityName :
            return favouriteFRC.fetchedObjects ?? []
        case ListeningPodcast.entityName :
            return listeningFRC.fetchedObjects ?? []
        case LikedMoment.entityName :
            return likeMomentFRC.fetchedObjects ?? []
        case ListSection.entityName:
            return listSectionFRC.fetchedObjects ?? []
        default:
            fatalError()
        }
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension FavouriteTableViewModel: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .delete:
           if let row = anObject as? Row {
              removeRow(row)
           }
        case .insert:
            guard let row = anObject as? Row,
                  let indexSection = getIndexSection(forRow: row) else { return }
            
            let sectionData = getSectionData(forIndex: indexSection)
            appendRow(row, toSectionData: sectionData)
        case .move:
           guard let index = indexPath?.row,
                 let newIndex = newIndexPath?.row else { return }
           if let listSection = anObject as? ListSection {
              guard let sectionData = getSectionData(forListSection: listSection) else { return }
              moveSectionData(sectionData, from: index, to: newIndex)
           }
        case .update:
            if let listSection = anObject as? ListSection {
                guard let sectionData = getSectionData(forListSection: listSection),
                      listSection.isActive != sectionData.isActive else { return }
                
                if !listSection.isActive {
                    deactivateSectionData(sectionData)
                } else {
                    activateSectionData(sectionData)
                }
            }
        default:
            break
        }
    }
}

