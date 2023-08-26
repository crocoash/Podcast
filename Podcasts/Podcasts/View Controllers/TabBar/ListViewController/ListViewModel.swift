//
//  ListViewModel.swift
//  Podcasts
//
//  Created by Anton on 11.08.2023.
//

import Foundation
import CoreData

class ListViewModel: NSObject {
   
   struct Section {
      
      var rows: [NSManagedObject]
      var isActive: Bool
      var sectionName: String
      var nameOfEntity: String
      var sequenceNumber: Int
      
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
                                                                        with: [NSSortDescriptor(key: #keyPath(ListSection.sequenceNumber), ascending: true)],
                                                                        predicates: [NSPredicate(format: "isActive = %d", true)])
   
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
      
      try? favouriteFRC.performFetch()
      try? likeMomentFRC.performFetch()
      try? listeningFRC.performFetch()
      
      configureSections()
   }
   
   ///active
   func isFirstElementInSection(at index: Int) -> Bool {
      if activeSections.isEmpty {
         return sections[index].rows.count == 1
      }
      return true
   }
   
   ///active
   var isOnlyOneSection: Bool { return countOfActiveSections == 1 }
   
   ///active
   var countOfActiveSections: Int {
      return activeSections.indices.reduce(into: 0) { $0 += sectionIsActive(at: $1) ? 1 : 0 }
   }
   
   ///active
   func isLastSection(at index: Int) -> Bool {
      countOfActiveSections == index + 1
   }
   
   ///active
   func getIndexOfActiveSection(forAny object: Any) -> Int? {
      guard let object = object as? NSManagedObject else { fatalError() }
      return activeSections.firstIndex(where: { $0.nameOfEntity == object.entityName })
   }
   
   func getIndexOfActiveSection(for index: Int) -> Int {
      var count = 0
      for i in (0...index) {
         if sectionIsEmpty(sections[i]) {
            count += 1
         }
      }
      return count == 0 ? 0 : (count - 1)
   }
   
   func moveSection(from index: Int, to newIndex: Int) {
      let section = sections[index]
      sections[index].sequenceNumber = newIndex
      
      sections.remove(at: index)
      sections.insert(section, at: newIndex)
   }
   
   ///active
   func getIndexPath(forAny object: Any, in sections: [Section]? = nil) -> IndexPath? {
      
      if let object = object as? FavouritePodcast {
         return getIndexPath(forEntity: object, in: sections)
      } else if let object = object as? ListeningPodcast {
         return getIndexPath(forEntity: object, in: sections)
      } else if let object = object as? LikedMoment {
         return getIndexPath(forEntity: object, in: sections)
      }
      
      return nil
   }
   
   ///active
   func getIndexPath<T: NSManagedObject>(forEntity object: T, in sections: [Section]? = nil) -> IndexPath? {
      for (sectionIndex, items) in (sections ?? activeSections).enumerated() {
         if let indexRow = items.rows.firstIndex(of: object) {
            return IndexPath(row: indexRow, section: sectionIndex)
         }
      }
      return nil
   }
   
   func getObjectInActiveSection(for indexPath: IndexPath) -> NSManagedObject {
      return activeSections[indexPath.section].rows[indexPath.row]
   }
   
   func getObjectsInActiveSections(for indexPath: IndexPath) -> [NSManagedObject] {
      return activeSections[indexPath.section].rows
   }
   
   func getNameOfActiveSection(for index: Int) -> String {
      return activeSections[index].sectionName
   }
   
   func getNameOfSection(for index: Int) -> String {
      return sections[index].sectionName
   }
   
   ///active
   func getCountOfRowsInSection(section index: Int) -> Int {
      return activeSections[index].rows.count
   }
   
   func remove(_ object: Any) {
      guard let indexPath = getIndexPath(forAny: object, in: sections) else { return }
      
      let sectionIndex = indexPath.section
      let rowIndex = indexPath.row
      
      sections[sectionIndex].rows.remove(at: rowIndex)
      //        if sections[sectionIndex].rows.isEmpty {
      //            sections.remove(at: sectionIndex)
      //        }
   }
   
   func appendItem(_ object: Any, at index: Int) {
      if let object = object as? NSManagedObject {
         guard let indexSection = sections.firstIndex(where: { $0.nameOfEntity == object.entityName }) else { fatalError() }
         sections[indexSection].rows.insert(object, at: index)
      }
   }
}

//MARK: - Private Methods
extension ListViewModel {
   
   private func configureSections() {
      let sections: [(name: String, entities: [NSManagedObject])] =
      [(name: FavouritePodcast.entityName, entities: favouriteFRC.fetchedObjects ?? []),
       (name: LikedMoment.entityName,      entities: likeMomentFRC.fetchedObjects ?? []),
       (name: ListeningPodcast.entityName, entities: listeningFRC.fetchedObjects ?? [])]
      
      
      func createSection(for section: (name: String, entities: [NSManagedObject])) -> Section {
         
         let name = section.name
         
         guard let listSections = listSectionFRC.fetchedObjects,
               let listSection = listSections.filter({ $0.nameOfEntity == name }).first else { fatalError() }
         
         return Section(entities: section.entities, listSection: listSection)
      }
      
      self.sections = sections.map { createSection(for: $0) }
      self.sections.sort { $0.sequenceNumber < $1.sequenceNumber }
   }
   
   private var activeSections: [Section] {
      return sections.filter { sectionIsEmpty($0) }
   }
   
   ///active
   private func sectionIsActive(at index: Int) -> Bool {
      return !activeSections[index].rows.isEmpty
   }
   
   func sectionIsEmpty(_ section: Section) -> Bool {
      return !section.rows.isEmpty
   }
   
   func getSection(by name: String) -> Section? {
      return sections.first { $0.sectionName == name }
   }
}
