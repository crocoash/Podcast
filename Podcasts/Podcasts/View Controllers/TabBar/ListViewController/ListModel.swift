//
//  ListModel.swift
//  Podcasts
//
//  Created by Anton on 07.09.2023.
//

import Foundation
import CoreData


struct SectionDocument {
    
    enum TypeOfSection {
        case active
        case all
    }
    
    private var sections: [Section] = []
    private var searchedSection: String? = nil
    
    
    var activeSections: [Section] {
        return sections.filter { sectionIsActive($0) }
    }
    
    func getSection(for index: Int, typeOfSection: TypeOfSection) -> Section {
        switch typeOfSection {
        case .active:
            return activeSections[index]
        case .all:
            return sections[index]
        }
    }
    
    func sectionIsActive(_ section: Section) -> Bool {
       return !section.rows.isEmpty && searchedSection == nil ? true : section.sectionName == searchedSection
    }
    
    func getIndexSection(by name: String, typeOfSection: TypeOfSection) -> Int? {
        switch typeOfSection {
        case .active:
            return activeSections.firstIndex { $0.nameOfEntity == name}
        case .all:
            return sections.firstIndex { $0.nameOfEntity == name }
        }
    }
    
    func getRows(in section: Int, typeOfSection: TypeOfSection) -> [NSManagedObject] {
        switch typeOfSection {
        case .active:
            return activeSections[section].rows
        case .all:
            return sections[section].rows
        }
    }
    
    func getRow(forIndexPath indexPath: IndexPath, typeOfSection: TypeOfSection) -> NSManagedObject {
        switch typeOfSection {
        case .active:
            return getRows(in: indexPath.section, typeOfSection: .active)[indexPath.row]
        case .all:
            return getRows(in: indexPath.section, typeOfSection: .all)[indexPath.row]
        }
    }
    
    var nameOfActiveSections: [String] {
       return activeSections.map { $0.sectionName }
    }
    
    mutating func setNewSections(_ sections: [Section]) {
        self.sections = sections
    }
    
    mutating func changeSearchedSection(searchedSection index: Int?) {
        searchedSection = nil
        guard let index = index, !activeSections.isEmpty else { return }
        let sections = sections.filter { !$0.rows.isEmpty }
        searchedSection = sections[index].sectionName
    }
    
    mutating func insert(_ section: Section, at index: Int) {
        sections.insert(section, at: index)
    }
    
    mutating func insertRow(row: NSManagedObject, at indexPath: IndexPath) {
        sections[indexPath.section].insertRow(row: row, at: indexPath.row)
    }
    
    mutating func remove(at index: Int) {
        sections.remove(at: index)
    }
    
    mutating func append(_ section: Section) {
        sections.append(section)
    }
    
    mutating func removeRow(at indexPath: IndexPath) {
        sections[indexPath.section].removeRow(at: indexPath.row)
    }
    
    mutating func getIndexPath(forRow row: NSManagedObject, typeOfSection: TypeOfSection) -> IndexPath? {
        var indexPath: IndexPath?
        
        var section: [Section] = []
        
        switch typeOfSection {
        case .active:
            section = activeSections
        case .all:
            section = sections
        }
        
        section.enumerated { sectionIndex, section in
            if let rowIndex = section.getIndex(forRow: row) {
                indexPath = IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        return indexPath
    }
    
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
        
        mutating func sectionIsActive(_ value: Bool) {
            isActive = value
        }
        
        func getIndex(forRow row: NSManagedObject) -> Int? {
            return rows.firstIndex(where: { $0 == row })
        }
        
        mutating func removeRow(at index: Int) {
            rows.remove(at: index)
        }
        
        mutating func insertRow(row: NSManagedObject, at index: Int) {
            if rows.count - 1 < index {
                rows.insert(row, at: index)
            } else {
                rows.append(row)
            }
        }
    }
}


