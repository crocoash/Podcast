//
//  BaseSectionData.swift
//  Podcasts
//
//  Created by Anton on 23.09.2023.
//

import Foundation

protocol ISectionData: Equatable {
    associatedtype Row: Hashable
    associatedtype Section: Hashable
    
    var section: Section  { get }
    var rows: [Row]       { get set }
    var isActive: Bool    { get set }
    var isAvailable: Bool { get }
    
    @MainActor mutating func insertNewRow(_ row: Row, atIndex index: Int)
    @MainActor mutating func appendNewRow(_ row: Row)
//    func changeSearchState(_ value: Bool)
    @MainActor mutating func removeAllRows()
    @MainActor mutating func removeRow(atIndex index: Int)
    @MainActor mutating func changeActiveState(newValue value: Bool)
}

extension ISectionData {
    var isEmpty: Bool { rows.isEmpty }
    mutating func insertNewRow(_ row: Row, atIndex index: Int) {
        rows.insert(row, at: index)
    }
    
    @MainActor mutating func appendNewRow(_ row: Row) {
        guard Thread.isMainThread else { fatalError()}
        rows.append(row)
    }
    
    mutating func changeActiveState(newValue value: Bool) {
        isActive = value
    }
    
    var isAvailable: Bool {
        return !isEmpty && isActive
    }
    
    mutating func removeAllRows() {
        rows.removeAll()
    }
    
    mutating func removeRow(atIndex index: Int) {
        rows.remove(at: index)
    }
}

struct BaseSectionData<Row: Hashable & Sendable, Section: Hashable & Sendable>: Equatable & ISectionData {
  
  static func == (lhs: BaseSectionData<Row, Section>, rhs: BaseSectionData<Row, Section>) -> Bool {
        lhs.section == rhs.section
  }
    
    var section: Section
    var rows: [Row]
    var isActive: Bool = true
    
    init(section: Section, rows: [Row]) {
        self.section = section
        self.rows = rows
    }
}
