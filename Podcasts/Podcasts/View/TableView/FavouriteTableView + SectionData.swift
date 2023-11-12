//
//  FavouriteTableView + SectionData.swift
//  Podcasts
//
//  Created by Anton on 25.09.2023.
//

import CoreData

//MARK: - SectionData
extension FavouriteTableViewModel {
    
    class SectionData: ISearchedSectionData {
        
        typealias Row = NSManagedObject
        typealias Section = String
        
        var section: String
        var rows: [NSManagedObject]
        var isActive: Bool
        var isSearched: Bool?
        
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
        
        static func == (lhs: FavouriteTableViewModel.SectionData, rhs: FavouriteTableViewModel.SectionData) -> Bool {
            lhs.section == rhs.section
        }
    }
}
