//
//  ListViewModel.swift
//  Podcasts
//
//  Created by Anton on 11.08.2023.
//

import Foundation
import CoreData

class ListViewModel: NSObject {
   
   struct Section: Equatable {
      
      var rows: [NSManagedObject]
      var isActive: Bool
      var sectionName: String
      var nameOfEntity: String
      var sequenceNumber: Int
      
      static func == (lhs: Section, rhs: Section) -> Bool {
         return lhs.sectionName == rhs.sectionName
      }
      
      init(entities: [NSManagedObject], listSection: ListSection) {
         self.rows = entities
         self.isActive = listSection.isActive
         self.sectionName = listSection.nameOfSection
         self.sequenceNumber = Int(truncating: listSection.sequenceNumber)
         self.nameOfEntity = listSection.nameOfEntity
      }
   }
   
   private let dataStoreManager: DataStoreManagerInput
   private let listDataManager: ListDataManagerInput
   
   lazy private var favouriteFRC = dataStoreManager.conFigureFRC(for: FavouritePodcast.self)
   lazy private var likeMomentFRC = dataStoreManager.conFigureFRC(for: LikedMoment.self)
   lazy private var listeningFRC = dataStoreManager.conFigureFRC(for: ListeningPodcast.self)
   
   lazy private(set) var listSectionFRC = dataStoreManager.conFigureFRC(for: ListSection.self,
                                                                        with: [NSSortDescriptor(key: #keyPath(ListSection.sequenceNumber), ascending: true)])
   
   private(set) var sections: [Section] = []
   
   //MARK: Init
   init(vc: NSFetchedResultsControllerDelegate, dataStoreManager: DataStoreManagerInput, listDataManager: ListDataManagerInput) {
      
      self.dataStoreManager = dataStoreManager
      self.listDataManager = listDataManager
      
      super.init()
      
      self.favouriteFRC.delegate = vc
      self.likeMomentFRC.delegate = vc
      self.listeningFRC.delegate = vc
      self.listSectionFRC.delegate = vc
      
      configureSections()
   }
   
   var nameForScopeBar: [String] {
      return nameOfActiveSections.map { $0.components(separatedBy: " ").first ?? "" }
   }
   
   private var searchedSection: String? = nil
   
   func changeSearchedSection(searchedSection index: Int?) {
      searchedSection = nil
      guard let index = index, !activeSections.isEmpty else { return }
      let sections = sections.filter { !$0.rows.isEmpty }
      searchedSection = sections[index].sectionName
   }
   
   func performSearch(text: String?) {
      
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
      configureSections()
   }
   
   ///active
   var countOfActiveSections: Int {
      return activeSections.count
   }
   
   func moveSection(_ object: Any, from index: Int, to newIndex: Int,
                    moveSection: ((_ index: Int, _ newIndex: Int) -> ())) {
      
      if object is ListSection {
         let section = sections[index]
         let activeIndex = activeSections.firstIndex { $0 == section }
         
         sections.remove(at: index)
         sections.insert(section, at: newIndex)
         
         let activeNewIndex = activeSections.firstIndex { $0 == section }
         
         let sectionIsActive = sectionIsActive(section)
         
         if let activeIndex = activeIndex, let activeNewIndex = activeNewIndex {
            if sectionIsActive, activeIndex != activeNewIndex {
               moveSection(activeIndex, activeNewIndex)
            }
         }
      }
   }
   
   func getIndexPath(forAny object: Any, in sections: [Section]) -> IndexPath? {
      
      if let object = object as? FavouritePodcast {
         return getIndexPath(forEntity: object, in: sections)
      } else if let object = object as? ListeningPodcast {
         return getIndexPath(forEntity: object, in: sections)
      } else if let object = object as? LikedMoment {
         return getIndexPath(forEntity: object, in: sections)
      }
      
      return nil
   }
  
   func getIndexPath<T: NSManagedObject>(forEntity object: T, in sections: [Section]) -> IndexPath? {
      for (sectionIndex, items) in (sections).enumerated() {
         if let indexRow = items.rows.firstIndex(of: object) {
            return IndexPath(row: indexRow, section: sectionIndex)
         }
      }
      return nil
   }
   
   func getObjectInSection(for indexPath: IndexPath) -> NSManagedObject {
      return activeSections[indexPath.section].rows[indexPath.row]
   }
   
   func getObjectsInSections(for indexPath: IndexPath) -> [NSManagedObject] {
      return activeSections[indexPath.section].rows
   }
   
   func getNameOfSection(for index: Int) -> String {
      return activeSections[index].sectionName
   }
   
   func getCountOfRowsInSection(section index: Int) -> Int {
      return activeSections[index].rows.count
   }
   
   func remove(_ object: Any,
               removeSection: ((_ index: Int) -> ()),
               removeItem: ((_ indexPath: IndexPath) -> () )) {
      
      guard let indexPath = getIndexPath(forAny: object, in: sections) else { return }
      
      if object is ListSection {
         ///Section
         let index = indexPath.row
         let section = sections[index]
         if sectionIsActive(section) {
            let index = activeSections.firstIndex { $0.sectionName == section.sectionName }
            guard let index = index else { return }
            removeSection(index)
         }
         sections.remove(at: index)
      } else {
         guard let indexPath = getIndexPath(forAny: object, in: sections) else { return }
         
         if sectionIsActive(sections[indexPath.section]) {
            guard let indexPath = getIndexPath(forAny: object, in: activeSections) else { return }
            removeItem(indexPath)
         }
         
         guard let index = activeSections.firstIndex(where: { $0 == sections[indexPath.section] }) else { return }
         sections[indexPath.section].rows.remove(at: indexPath.row)
         
         if !sectionIsActive(sections[indexPath.section]) {
            removeSection(index)
         }
      }
   }
   
   func append(_ object: Any, at newIndexPath: IndexPath?,
                   insertSection: ((_ section: Section,_ index: Int) -> ()),
                   insertItem: ((_ indexPath: IndexPath) -> ())) {
      
      guard let indexPath = newIndexPath else { return }
      
      ///Section
      if let section = object as? ListSection {
         let index = indexPath.row
         let rows = getRowsFor(entityName: section.nameOfEntity)
         let section = Section(entities: rows, listSection: section)
         if sections.count - 1 < indexPath.row {
            sections.append(section)
         } else {
            sections.insert(section, at: index)
         }
         
         guard let newIndex = activeSections.firstIndex(where: { $0 == section }) else { return }
         insertSection(section, newIndex)
         
         if sectionIsActive(section) {
            for (indexRow, row) in rows.enumerated() {
               let indexPath = IndexPath(row: index, section: indexRow)
               append(row, at: indexPath) { section, index in } insertItem: { indexPath in
                  insertItem(indexPath)
               }
            }
         }
         
         /// row
      } else  {
         guard let object = object as? NSManagedObject else { return }
         let indexSection = sections.firstIndex { $0.nameOfEntity == object.entityName }
         guard let indexSection = indexSection else { fatalError() }
         
         let section = sections[indexSection]
         var indexPath = IndexPath(row: indexPath.row, section: indexSection)
         
         let isFirstElementInSection = section.rows.isEmpty
         
         sections[indexPath.section].rows.insert(object, at: indexPath.row)
         
         let activeSectionIndex = activeSections.firstIndex { $0 == section }
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
   
   private func configureSections() {
      var sections = (listSectionFRC.fetchedObjects ?? []).map {
         let entities = getRowsFor(entityName: $0.nameOfEntity)
         return Section(entities: entities, listSection: $0)
      }
      
      sections.sort { $0.sequenceNumber < $1.sequenceNumber }
      self.sections = sections
   }
   
   var activeSections: [Section] {
      return sections.filter { sectionIsActive($0) }
   }
   
   private var nameOfActiveSections: [String] {
      return activeSections.map { $0.sectionName }
   }
   
   private func sectionIsActive(_ section: Section) -> Bool {
      return !section.rows.isEmpty && searchedSection == nil ? true : section.sectionName == searchedSection
   }
}
