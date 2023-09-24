//
//  ListViewModel + SectionData.swift
//  Podcasts
//
//  Created by Anton on 22.09.2023.
//

import Foundation
import CoreData


extension NSManagedObject: Identifiable {}


//MARK: - SectionData
extension ListViewModel {
    
    class SectionData: ISectionData {
        
        typealias Row = NSManagedObject
        typealias Section = String
        
        var section: String
        var rows: [NSManagedObject]
        var isActive: Bool
        var isActiveAndNotEmpty: Bool {
            return isActive && !isEmpty
        }
        var nameOfEntity: String
        var sequenceNumber: Int
        
        //MARK: init
        init(listSection: ListSection, rows: [NSManagedObject]) {
            self.rows = rows
            self.isActive = listSection.isActive
            self.section = listSection.nameOfSection
            self.sequenceNumber = Int(truncating: listSection.sequenceNumber)
            self.nameOfEntity = listSection.nameOfEntity
        }
        
        static func == (lhs: ListViewModel.SectionData, rhs: ListViewModel.SectionData) -> Bool {
            lhs.section == rhs.section
        }
    }
}
