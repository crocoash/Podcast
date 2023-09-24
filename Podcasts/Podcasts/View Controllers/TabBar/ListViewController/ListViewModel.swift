//
//  ListViewModel.swift
//  Podcasts
//
//  Created by Anton on 11.08.2023.
//

import Foundation
import CoreData

class ListViewModel: NSObject, IPerRequest, ITableViewDinamicUpdating {
  
   typealias Arguments = Void
   
   var insertSectionOnView: ((SectionData, Int) -> ()) = { _, _ in }
   var insertItemOnView:    ((Row, IndexPath) -> ())   = { _, _ in }
   var removeRowOnView:    ((IndexPath) -> ())        = {    _ in }
   var removeSectionOnView: ((Int) -> ())              = {    _ in }
   var moveSectionOnView:   ((Int, Int) -> ())         = { _, _ in }

   private let dataStoreManager: DataStoreManager
   private var searchedText = ""
   
   lazy private var favouriteFRC = dataStoreManager.conFigureFRC(for: FavouritePodcast.self)
   lazy private var likeMomentFRC = dataStoreManager.conFigureFRC(for: LikedMoment.self)
   lazy private var listeningFRC = dataStoreManager.conFigureFRC(for: ListeningPodcast.self)
   
   lazy private(set) var listSectionFRC = dataStoreManager.conFigureFRC(for: ListSection.self,
                                                                        with: [NSSortDescriptor(key: #keyPath(ListSection.sequenceNumber), ascending: true)],
                                                                        predicates: [NSPredicate(format: "isActive = %d", true)])
   var searchedSection: String?

   var dataSourceForView: [SectionData] = []
   var dataSourceAll: [SectionData] = [] {
      didSet {
         dataSourceForView = configureDataSourceOutput()
      }
   }
   
   //MARK: Init
   required init(container: IContainer, args: Arguments) {
      
      self.dataStoreManager = container.resolve()
      self.dataSourceAll = []
      super.init()
      
      favouriteFRC.delegate = self
      likeMomentFRC.delegate = self
      listeningFRC.delegate = self
      listSectionFRC.delegate = self
      
      self.dataSourceAll = configureDataSource()
      self.dataSourceForView = configureDataSourceOutput()
   }
   
   lazy var sectionCountChanged: (() -> (Int)) = { [weak self] in
      guard let self = self else { return 0 }
      return numbersOfSections
   }
   
   var isSearching: Bool {
      return searchedText != ""
   }
   
//   var nameForScopeBar: [String] {
//      return sectionsDocument.nameOfActiveSections.map { $0.components(separatedBy: " ").first ?? "" }
//   }

   func changeSearchedSection(searchedSection index: Int?) {
//      searchedSection = nil
      guard let index = index, !sectionsIsEmpty else { return }
//      let sections = sections.filter { !$0.rows.isEmpty }
      searchedSection = getInputSection(sectionIndex: index)
   }
   
   func performSearch(text: String?) {
      performSearch(text)
   }
   
   func getPlaylist(for section: Int) -> [Podcast] {
      let objects = getRows(atSection: section)
      switch objects {
      case let favourites as [FavouritePodcast]:
         return favourites.map { $0.podcast }
      case let likes as [LikedMoment]:
         return likes.map { $0.podcast }
      case let listeningPodcasts as [ListeningPodcast]:
         return listeningPodcasts.map { $0.podcast }
      default:
         fatalError()
      }
   }
   
//   func getNameOfSection(for index: Int) -> String {
//      return getSectionData(forIndex: index).section
//   }
}

//MARK: - Private Methods
extension ListViewModel {
   
   private func getRowsFor(entityName: String) -> [NSManagedObject] {
      switch entityName {
      case FavouritePodcast.entityName :
         return favouriteFRC.fetchedObjects ?? []
      case ListeningPodcast.entityName :
         return listeningFRC.fetchedObjects ?? []
      case LikedMoment.entityName :
         return likeMomentFRC.fetchedObjects ?? []
      default:
         break
      }
      fatalError()
   }
   
   private func configureDataSourceOutput() -> [SectionData] {
      return dataSourceAll.filter { sectionIsActive($0) }
   }
   
   private func sectionIsActive(_ sectionData: SectionData) -> Bool {
      sectionData.isActiveAndNotEmpty && searchedSection == nil ? true : sectionData.section == searchedSection
   }
   
   private func configureDataSource() -> [SectionData] {
      var sectionData = listSectionFRC.fetchedObjects?.map {
         let entities = getRowsFor(entityName: $0.nameOfEntity)
         return SectionData(listSection: $0, rows: entities)
      }
      sectionData?.sort { $0.sequenceNumber < $1.sequenceNumber }
      return sectionData ?? []
   }
   
   private func performSearch(_ text: String?) {
      self.searchedText = text ?? ""
      
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
      
      let newSections = configureDataSource().filter { sectionIsActive($0) }
      update(by: newSections)
   }
   
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
   
   private func getIndexSection(forRow row: Row) -> Int? {
      for (indexSection, sectionData) in dataSourceAll.enumerated() {
         if row.entityName == sectionData.nameOfEntity {
           return indexSection
         }
      }
      return nil
   }
}


//MARK: - NSFetchedResultsControllerDelegate
extension ListViewModel: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .delete:
           if let listSection = anObject as? ListSection {
              guard let sectionData = getSectionData(forListSection: listSection) else { return }
              removeSection(sectionData)
           } else if let row = anObject as? Row {
              removeRow(row)
           }
        case .insert:
           if let listSection = anObject as? ListSection {
              let rows = getRowsFor(entityName: listSection.entityName)
              let section = SectionData(listSection: listSection, rows: rows)
              guard let index = indexPath?.row else { return }
              insertSectionData(section, atNewIndex: index)
           } else if let row = anObject as? Row {
              if var newIndexPath = newIndexPath, let indexSection = getIndexSection(forRow: row) {
                 newIndexPath.section = indexSection
                 appendRow(row, at: newIndexPath)
              }
           }
        case .move:
           guard let index = indexPath?.row,
                 let newIndex = newIndexPath?.row else { return }
           if let listSection = anObject as? ListSection {
              guard let sectionData = getSectionData(forListSection: listSection) else { return }
              moveSectionData(sectionData, from: index, to: newIndex)
           }
           
        case .update:
            update(with: anObject) { indexPaths in
//                todo
            }
        default:
            break
        }
    }
}

