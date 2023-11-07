//
//  ITableViewModel.swift
//  Podcasts
//
//  Created by Anton on 06.11.2023.
//

import UIKit

//MARK: - TableView model
protocol ITableViewModel: AnyObject {
    associatedtype SectionData: ISectionData
    
    typealias Row = SectionData.Row
    typealias Section = SectionData.Section
    
    var dataSourceForView: [SectionData] { get }
    
    func getCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell
}

extension ITableViewModel {
    
    var numbersOfSections: Int {
        return dataSourceForView.count
    }
    
    var isEmpty: Bool {
        return numbersOfSections == 0
    }
    
    var sections: [Section] {
        return dataSourceForView.map { $0.section }
    }
    
    func numbersOfRowsInSection(section index: Int) -> Int {
        return dataSourceForView[index].rows.count
    }
    
    func getSection(sectionIndex index: Int) -> Section {
        return dataSourceForView[index].section
    }
   
    func getRows(atSection index: Int) -> [Row] {
        return dataSourceForView[index].rows
    }

    func getRow(forIndexPath indexPath: IndexPath) -> Row {
        return getRows(atSection: indexPath.section)[indexPath.row]
    }
    
    func getIndexSectionForView(forSection section: Section) -> Int? {
        return dataSourceForView.firstIndex { $0.section == section }
    }
    
    func getSectionData(at index: Int) -> SectionData {
        return dataSourceForView[index]
    }
    
    func getIndexPathForView(forRow row: Row) -> IndexPath? {
        for (indexSection, sectionData) in dataSourceForView.enumerated() {
            for (indexRow, row1) in sectionData.rows.enumerated() {
                if row == row1 {
                    return IndexPath(row: indexRow, section: indexSection)
                }
            }
        }
        return nil
    }
}
