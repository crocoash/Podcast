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
    
    var section: Section  { get set }
    var rows: [Row]       { get set }
    var isActive: Bool    { get set }
    var isAvailable: Bool { get }
}


extension ISectionData {
    var isEmpty: Bool { rows.isEmpty }
//    var isAvailable: Bool {
//        return !isEmpty && isActive
//    }
}

class BaseSectionData<Row, Section>: ISectionData {
    var isAvailable: Bool {
        return !isEmpty && isActive
    }
    
    
    static func == (lhs: BaseSectionData<Row, Section>, rhs: BaseSectionData<Row, Section>) -> Bool {
        lhs.rows == rhs.rows
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
