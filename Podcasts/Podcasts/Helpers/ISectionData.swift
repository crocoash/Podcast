//
//  BaseSectionData.swift
//  Podcasts
//
//  Created by Anton on 23.09.2023.
//

import Foundation

 protocol ISectionData: Equatable, Sendable {
    associatedtype Row: Hashable
    associatedtype Section: Hashable
    
    var section: Section  { get set }
    var rows: [Row]       { get set }
    var isActive: Bool    { get set }
    var isAvailable: Bool { get }
}


extension ISectionData {
    var isEmpty: Bool { rows.isEmpty }
}

struct BaseSectionData<Row, Section>: ISectionData, @unchecked Sendable {
    var isAvailable: Bool {
        return !isEmpty && isActive
    }
    
    static func == (lhs: BaseSectionData<Row, Section>, rhs: BaseSectionData<Row, Section>) -> Bool {
        lhs.section == rhs.section
    }
    
     var isSearched: Bool?
     var section: String
     var rows: [Podcast]
     var isActive: Bool = true
    
    init(section: String, rows: [Podcast]) {
        self.section = section
        self.rows = rows
    }
}

extension Collection where Element == any ISectionData {
    
    
    
    
}
