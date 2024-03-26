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
    
    var dataSourceForView: [SectionData] { get set }
    func getCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell
}


extension ITableViewModel {
    
    func update(dataSource: [SectionData]) {
        dataSourceForView = dataSource
    }
    
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
    
    func getSectionForView(sectionIndex index: Int) -> Section {
        return dataSourceForView[index].section
    }
   
    func getRowsForView(atSection index: Int) -> [Row] {
        return dataSourceForView[index].rows
    }

    func getRowForView(forIndexPath indexPath: IndexPath) -> Row {
        return getRowsForView(atSection: indexPath.section)[indexPath.row]
    }
    
    func getIndexSectionForView(forSection section: Section) -> Int? {
        return dataSourceForView.firstIndex { $0.section == section }
    }
    
    func getSectionDataForView(at index: Int) -> SectionData {
        return dataSourceForView[index]
    }
    
    func getIndexPathOfRowForView(forRow row: Row, inSection section: Section) async -> IndexPath? {
        for (indexSection, sectionData1) in dataSourceForView.enumerated() {
            if sectionData1.section == section {
                for (indexRow, row1) in sectionData1.rows.enumerated() {
                    if row == row1 {
                        return IndexPath(row: indexRow, section: indexSection)
                    }
                }
            }
        }
        return nil
    }
}
