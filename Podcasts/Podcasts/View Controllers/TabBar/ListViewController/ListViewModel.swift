//
//  ListViewModel.swift
//  Podcasts
//
//  Created by Anton on 11.08.2023.
//

import Foundation
import CoreData

class ListViewModel {
    
    struct Section {
        
        var rows: [NSManagedObject]
        var isActive: Bool = true
        
        init(entities: [NSManagedObject]) {
            self.rows = entities
        }
    }
    private let dataStoreManager: DataStoreManagerInput
    
    lazy private var favouriteFRC = dataStoreManager.conFigureFRC(for: FavouritePodcast.self, with: nil)
    lazy private var likeMomentFRC = dataStoreManager.conFigureFRC(for: LikedMoment.self, with: nil)
    lazy private var listeningFRC = dataStoreManager.conFigureFRC(for: ListeningPodcast.self, with: nil)
    
    private var sections: [Section] = []
    
    init(vc: NSFetchedResultsControllerDelegate, dataStoreManager: DataStoreManagerInput) {
        
        self.dataStoreManager = dataStoreManager
        
        let sections: [[NSManagedObject]] = [favouriteFRC.fetchedObjects ?? [],
                                             listeningFRC.fetchedObjects ?? [],
                                             likeMomentFRC.fetchedObjects ?? []].filter( { !$0.isEmpty })
                
        self.sections = sections.map { Section(entities: $0 )}
        
        self.favouriteFRC.delegate = vc
        self.likeMomentFRC.delegate = vc
        self.listeningFRC.delegate = vc
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
        
        
    }
    
    func isFirstElementInSection(at indexPath: IndexPath) -> Bool {
        if sections.isEmpty {
            return sections[indexPath.section].rows.count == 0
        }
        return true
    }
    
    var isOnlyOneSection: Bool {
        return sections.count == 1
    }
    
    var countOfSections: Int {
        return sections.count
    }
    
    func isLastSection(at indexPath: IndexPath) -> Bool {
        sections.count == indexPath.section + 1
    }
    
    func getIndexOfSection(forAny object: Any) -> Int? {
        guard let object = object as? NSManagedObject else { return nil }
        return sections.firstIndex(where: { $0.rows.first?.entityName == object.entityName })
    }
    
    func getIndexPath(forAny object: Any) -> IndexPath? {
        
        if let object = object as? FavouritePodcast {
            return getIndexPath(forEntity: object)
        } else if let object = object as? ListeningPodcast {
            return getIndexPath(forEntity: object)
        } else if let object = object as? LikedMoment {
            return getIndexPath(forEntity: object)
        }
        
        return nil
    }
    
    func getIndexPath<T: NSManagedObject>(forEntity object: T) -> IndexPath? {
        for (sectionIndex, items) in sections.enumerated() {
            if let indexRow = items.rows.firstIndex(of: object) {
                return IndexPath(row: indexRow, section: sectionIndex)
            }
        }
        return nil
    }
    
    func remove(_ object: Any) {
        guard let indexPath = getIndexPath(forAny: object) else { return }
        
        let sectionIndex = indexPath.section
        let rowIndex = indexPath.row
        
        sections[sectionIndex].rows.remove(at: rowIndex)
        if sections[sectionIndex].rows.isEmpty {
            sections.remove(at: sectionIndex)
        }
    }
    
    func appendItem(_ object: Any, at index: Int) {
        if let object = object as? NSManagedObject {
            if let indexSection = getIndexOfSection(forAny: object) {
                sections[indexSection].rows.insert(object, at: index)
            } else {
                let section = Section(entities: [object])
                sections.append(section)
            }
        }
    }
    
    func getObject(for indexPath: IndexPath) -> NSManagedObject {
        return sections[indexPath.section].rows[indexPath.row]
    }
    
    func getObjects(for indexPath: IndexPath) -> [NSManagedObject] {
        return sections[indexPath.section].rows
    }
    
    func getNameOfSection(for index: Int) -> String? {
        return sections[index].rows.first?.entityName
    }
    
    func getCountOfRowsInSection(section index: Int) -> Int {
        return sections[index].rows.count
    }
}

