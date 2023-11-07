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
    
    var section: Section { get set }
    var rows: [Row]      { get set }
    var isActive: Bool   { get }
}


extension ISectionData {
    var isEmpty: Bool { rows.isEmpty }
    var isActiveAndNotEmpty: Bool { !isEmpty && isActive }
}

class BaseSectionData<Row, Section>: ISectionData {
    
    static func == (lhs: BaseSectionData<Row, Section>, rhs: BaseSectionData<Row, Section>) -> Bool {
        lhs.rows == rhs.rows
    }
  
    var section: String
    var rows: [Podcast]
    var isActive: Bool = true
    
    init(section: String, rows: [Podcast]) {
        self.section = section
        self.rows = rows
    }
}
