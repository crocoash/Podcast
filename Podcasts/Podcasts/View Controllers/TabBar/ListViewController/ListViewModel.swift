//
//  ListViewModel.swift
//  Podcasts
//
//  Created by Anton on 11.08.2023.
//

import Foundation
import CoreData

class ListViewModel: IPerRequest {
  
   typealias Arguments = NSFetchedResultsControllerDelegate
   typealias Section = SectionDocument.Section
   
   private let dataStoreManager: DataStoreManager
   private var searchedText = ""
   
   lazy private var favouriteFRC = dataStoreManager.conFigureFRC(for: FavouritePodcast.self)
   lazy private var likeMomentFRC = dataStoreManager.conFigureFRC(for: LikedMoment.self)
   lazy private var listeningFRC = dataStoreManager.conFigureFRC(for: ListeningPodcast.self)
   
   lazy private(set) var listSectionFRC = dataStoreManager.conFigureFRC(for: ListSection.self,
                                                                        with: [NSSortDescriptor(key: #keyPath(ListSection.sequenceNumber), ascending: true)],
                                                                        predicates: [NSPredicate(format: "isActive = %d", true)])
   
   private var sectionsDocument: SectionDocument = SectionDocument()
   
   //MARK: Init
   required init(container: IContainer, args: Arguments) {
      
      self.dataStoreManager = container.resolve()
  
      favouriteFRC.delegate = args
      likeMomentFRC.delegate = args
      listeningFRC.delegate = args
      listSectionFRC.delegate = args
      
      let sections = configureSections()
      sectionsDocument.setNewSections(sections)
   }
   
   lazy var sectionCountChanged: (() -> (Int)) = { [weak self] in
      guard let self = self else { return 0 }
      return sectionsDocument.activeSections.count
   }
   
   func configureSections() -> [Section] {
      var sections = (listSectionFRC.fetchedObjects ?? []).map {
         let entities = getRowsFor(entityName: $0.nameOfEntity)
         return Section(entities: entities, listSection: $0)
         
      }
      sections.sort { $0.sequenceNumber < $1.sequenceNumber }
      return sections
   }
   
   var sectionsIsEmpty: Bool {
      return sectionsDocument.activeSections.count == 0
   }
   
   var isSearchedText: Bool {
      return searchedText != ""
   }
   
   var nameForScopeBar: [String] {
      return sectionsDocument.nameOfActiveSections.map { $0.components(separatedBy: " ").first ?? "" }
   }
   
   func changeSearchedSection(searchedSection index: Int?) {
      sectionsDocument.changeSearchedSection(searchedSection: index)
   }
   
   func performSearch(text: String?,
                      removeSection: ((_ index: Int) -> ()),
                      removeItem: ((_ indexPath: IndexPath) -> ()),
                      insertSection: ((_ section: Section, _ index: Int) -> ()),
                      insertItem: ((_ indexPath: IndexPath) -> ())) {
      
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
      
      let newSections = configureSections().filter { sectionsDocument.sectionIsActive($0) }
      
      /// remove
      for section in sectionsDocument.activeSections {
         let rows = section.rows
         for row in rows {
            
            if newSections.isEmpty || !newSections.contains(section) {
               remove(row, removeSection: removeSection, removeItem: removeItem)
            } else {
               for newSection in newSections {
                  if newSection == section  {
                     let newRows = newSection.rows
                     
                     if !newRows.contains(row) {
                        remove(row, removeSection: removeSection, removeItem: removeItem)
                     }
                  }
               }
            }
         }
      }
      
      /// append
      newSections.enumerated { indexNewSection, newSection in
         let newRows = newSection.rows
         newRows.enumerated { indexNewRow, newRow in
            
            if sectionsDocument.activeSections.isEmpty || !sectionsDocument.activeSections.contains(newSection) {
               append(newRow, at: IndexPath(row: indexNewRow, section: indexNewSection), insertSection: insertSection, insertItem: insertItem)
            } else {
               for section in sectionsDocument.activeSections {
                  if newSection == section {
                     let rows = section.rows
                     if !rows.contains(newRow) {
                        append(newRow, at: IndexPath(row: indexNewRow, section: indexNewSection), insertSection: insertSection, insertItem: insertItem)
                     }
                  }
               }
            }
         }
      }
   }
   
   ///active
   var countOfSections: Int {
      return sectionsDocument.activeSections.count
   }
   
   func moveSection(_ object: Any, from index: Int, to newIndex: Int,
                    moveSection: ((_ index: Int, _ newIndex: Int) -> ())) {
      
      if object is ListSection {
         let section = sectionsDocument.getSection(for: index, typeOfSection: .all)
         let activeIndex = sectionsDocument.activeSections.firstIndex { $0 == section }
         
         sectionsDocument.remove(at: index)
         sectionsDocument.insert(section, at: newIndex)
         
         let activeNewIndex = sectionsDocument.activeSections.firstIndex { $0 == section }
         
         let sectionIsActive = sectionsDocument.sectionIsActive(section)
         
         if let activeIndex = activeIndex, let activeNewIndex = activeNewIndex {
            if sectionIsActive, activeIndex != activeNewIndex {
               moveSection(activeIndex, activeNewIndex)
            }
         }
      }
   }
   
   func update(with object: Any, reloadIndexPath: ([IndexPath]) -> ()) {
      if let podcast = (object as? ListeningPodcast)?.podcast {
         var indexPath: [IndexPath] = []
         sectionsDocument.activeSections.enumerated { indexSection, section in
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
   
   func getObjectInSection(for indexPath: IndexPath) -> NSManagedObject {
      return sectionsDocument.getRow(forIndexPath: indexPath, typeOfSection: .active)
   }
   
   func getObjectsInSections(for section: Int) -> [NSManagedObject] {
      return sectionsDocument.getRows(in: section, typeOfSection: .active)
   }
   
   func getNameOfSection(for index: Int) -> String {
      return sectionsDocument.getSection(for: index, typeOfSection: .active).sectionName
   }
   
   func getCountOfRowsInSection(section index: Int) -> Int {
      return sectionsDocument.getRows(in: index, typeOfSection: .active).count
   }
   
   func remove(_ object: Any,
               removeSection: ((_ index: Int) -> ()),
               removeItem: ((_ indexPath: IndexPath) -> () )) {
      
      if let listSection = object as? ListSection {
         ///Section
         guard let index = sectionsDocument.activeSections.firstIndex(where: { $0.sectionName == listSection.nameOfSection }) else { return }
         let section = sectionsDocument.activeSections[index]
         if sectionsDocument.sectionIsActive(section) {
            removeSection(index)
         }
         sectionsDocument.remove(at: index)
      } else {
         guard let object = object as? NSManagedObject,
               let indexPath = sectionsDocument.getIndexPath(forRow: object, typeOfSection: .all) else { return }
         
         let section = sectionsDocument.getSection(for: indexPath.section, typeOfSection: .all)

         if sectionsDocument.sectionIsActive(section) {
            guard let indexPath = sectionsDocument.getIndexPath(forRow: object, typeOfSection: .active) else { return }
            removeItem(indexPath)
         }
         //TODO: -
         guard let index = sectionsDocument.activeSections.firstIndex(where: { $0 == section }) else { return }
         sectionsDocument.removeRow(at: indexPath)
         
         if !sectionsDocument.sectionIsActive(section) {
            removeSection(index)
         }
      }
   }
   
   func append(_ object: Any, at newIndexPath: IndexPath?,
               insertSection: ((_ section: Section,_ index: Int) -> ()),
               insertItem: ((_ indexPath: IndexPath) -> ())) {
      
      guard let indexPath = newIndexPath else { return }
      
      ///Section
      if let listSection = object as? ListSection {
         let index = indexPath.row
         let rows = getRowsFor(entityName: listSection.nameOfEntity)
         let section = Section(entities: rows, listSection: listSection)
         //TODO: -
//         if sections.count - 1 < indexPath.row {
//            sectionsDocument.append(section)
//         } else {
            sectionsDocument.insert(section, at: index)
//         }
         
         guard let newIndex = sectionsDocument.activeSections.firstIndex(where: { $0 == section }) else { return }
         insertSection(section, newIndex)
         
         if sectionsDocument.sectionIsActive(section) {
            rows.enumerated { indexRow, row in
               let indexPath = IndexPath(row: index, section: indexRow)
               append(row, at: indexPath) { section, index in } insertItem: { indexPath in
                  insertItem(indexPath)
               }
            }
         }
         
         /// row
      } else  {
         guard let object = object as? NSManagedObject else { return }
         let indexSection = sectionsDocument.getIndexSection(by:  object.entityName, typeOfSection: .all)
         guard let indexSection = indexSection else { return }
         
         let section = sectionsDocument.getSection(for: indexSection, typeOfSection: .all)
         var indexPath = IndexPath(row: indexPath.row, section: indexSection)
         
         let isFirstElementInSection = section.rows.isEmpty
         
         sectionsDocument.insertRow(row: object, at: indexPath)
         
         let activeSectionIndex = sectionsDocument.activeSections.firstIndex { $0 == section }
         guard let activeSectionIndex = activeSectionIndex else { fatalError() }
         indexPath.section = activeSectionIndex
         
         if isFirstElementInSection && section.isActive {
            insertSection(section, indexPath.section)
         }
         
         insertItem(indexPath)
      }
   }
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
}
