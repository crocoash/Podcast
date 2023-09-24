//
//  ViewModelUpdating.swift
//  Podcasts
//
//  Created by Anton on 23.09.2023.
//

import Foundation


protocol ITableViewSorting {
    associatedtype TypeSortOfTableView
    
    var typeOfSort: TypeSortOfTableView { get set }
}



protocol ITableViewModel: AnyObject {
    associatedtype SectionData: ISectionData
    
    typealias Row = SectionData.Row
    typealias Section = SectionData.Section
    
    var dataSourceForView: [SectionData] { get }
}

extension ITableViewModel {
    
    var numbersOfSections: Int {
        return dataSourceForView.count
    }
    
    var sectionsIsEmpty: Bool {
        return numbersOfSections == 0
    }
    
    func numbersOfRowsInSection(section index: Int) -> Int {
        return dataSourceForView[index].rows.count
    }
    
    func getInputSection(sectionIndex index: Int) -> Section {
        return dataSourceForView[index].section
    }
   
    func getRows(atSection index: Int) -> [Row] {
        return dataSourceForView[index].rows
    }

    func getRow(forIndexPath indexPath: IndexPath) -> Row {
        return getRows(atSection: indexPath.section)[indexPath.row]
    }
    
    func getIndexForView(forSection section: Section) -> Int? {
        return dataSourceForView.firstIndex { $0.section == section }
    }
    
    func getIndexPathForView(forRow row: Row) -> IndexPath? {
        for (indexSection, sectionData) in dataSourceForView.enumerated() {
            for (indexRow, row1) in sectionData.rows.enumerated() {
                if row.id == row1.id {
                    return IndexPath(row: indexRow, section: indexSection)
                }
            }
        }
        return nil
    }
    
    func getIndexSectionForView(forSection section: Section) -> Int? {
        return dataSourceForView.firstIndex { $0.section == section }
    }
    
    var sections: [Section] { dataSourceForView.map { $0.section } }
}


//MARK: - ITableViewDinamicUpdating
protocol ITableViewDinamicUpdating: ITableViewModel {
    typealias Row = SectionData.Row
    typealias Section = SectionData.Section
    
    var dataSourceAll: [SectionData] { get set }
    
    var removeSectionOnView: ((_ index: Int                                   ) -> ()) { get set }
    var removeRowOnView:    ((_ indexPath: IndexPath                          ) -> ()) { get set }
    var insertSectionOnView: ((_ section: SectionData, _ index: Int           ) -> ()) { get set }
    var insertItemOnView:    ((_ item: Row,            _ indexPath: IndexPath ) -> ()) { get set }
    var moveSectionOnView:   ((_ index: Int,           _ newIndex: Int        ) -> ()) { get set }
    
    func update(by: [SectionData])
}


extension Collection where Element == any ISectionData {
    
   
    subscript(_ entity: any Identifiable) -> IndexPath? {
        for (sectionIndex, section) in self.enumerated() {
            for (rowIndex, row) in section.rows.enumerated() {
                if let idString = entity.id as? String {
                    if let rowId = row.id as? String {
                        if idString == rowId {
                            return IndexPath(row: rowIndex, section: sectionIndex)
                        }
                    }
                }
            }
        }
        return nil
    }
}

extension ITableViewDinamicUpdating {
    
    private func insertRow(row: Row, at indexPath: IndexPath) {
        dataSourceAll[indexPath.section].rows.insert(row, at: indexPath.row)
    }
    
//    private func getIndexSection(forRow row: Row) -> Int? {
//
//        for (indexSection, sectionData) in dataSource.enumerated() {
//            for (_, row1) in sectionData.rows.enumerated() {
//
//                if let row = row as? any CoreDataProtocol {
//                    if let row1 = row1 as? any CoreDataProtocol {
//
//                        if let row1Id = row1.id as? String, let rowId = row.id as? String {
//                            if row1Id == rowId {
//                                return indexSection
//                            }
//                        }
//                    }
//                }
////
//            }
//        }
//        return nil
//    }
    
    private func getIndexPath(forRow row: Row) -> IndexPath? {
        for (indexSection, sectionData) in dataSourceAll.enumerated() {
            for (indexRow, row1) in sectionData.rows.enumerated() {
                if row.id == row1.id {
                    return IndexPath(row: indexRow, section: indexSection)
                }
            }
        }
        return nil
    }
    
    private func getIndexSection(forSection section: Section) -> Int? {
        for (indexSection, sectionData) in dataSourceAll.enumerated() {
            if sectionData.section == section {
                return indexSection
            }
        }
        return nil
    }
    
    
    
    private func getSectionData(forIndex index: Int) -> SectionData {
        return dataSourceAll[index]
    }

    func update(by newDataSource: [SectionData]) {
        
        dataSourceAll.enumerated { indexSection, sectionData in
            let section = sectionData.section
            
            let newSections = newDataSource.map { $0.section }
            
            if newSections.isEmpty || !newSections.contains(section) {
                guard let index = getIndexSection(forSection: section) else { return }
                dataSourceAll.remove(at: index)
//                guard let index = getIndexSectionForView(forSection: section) else { return }
                removeSectionOnView(index)
            } else {
                for row in sectionData.rows {
                    newDataSource.enumerated { newIndexSection, newSection in
                        if newSection.section == sectionData.section {
                            if let index = dataSourceAll[indexSection].rows.firstIndex(where: { $0.id == row.id })  {
                                dataSourceAll[indexSection].rows.remove(at: index)
                                removeRowOnView(IndexPath(item: index, section: indexSection))
                            }
                        }
                    }
                }
            }
            //
            //         if section.rows.isEmpty {
            //            playlist.remove(at: indexSection)
            //            removeSection(indexSection)
            //         }
        }
        
        /// append
        newDataSource.enumerated { indexNewSection, newSectionData in
            let newSection = newSectionData.section
            
            newSectionData.rows.enumerated { indexNewRow, newRow in
                
                if !dataSourceAll.contains(where: { $0.section == newSection }) {
                    if !dataSourceAll.isEmpty, dataSourceAll.count - 1 < indexNewSection {
                        insertSectionData(newSectionData, atNewIndex: indexNewSection)
                    } else {
                        appendSectionData(newSectionData)
                    }
                } else {
                    dataSourceAll.enumerated { indexSection, sectionData in
                        if newSection == sectionData.section {
                            if !sectionData.rows.contains(where: { $0.id == newRow.id }) {
                                let index = sectionData.rows.count == 0 ? 0 : (sectionData.rows.count - 1)
                                let indexPath = IndexPath(row: index, section: indexSection)
                                dataSourceAll[indexSection].rows.insert(newRow, at: index)
                                insertItemOnView(newRow, indexPath)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func removeSection(_ completion: @escaping (_ index: Int) -> ()) {
        removeSectionOnView = completion
    }
    
    func removeRow(_ completion: @escaping ((_ indexPath: IndexPath) -> ())) {
        removeRowOnView = completion
    }
    
    func insertSection(_ completion: @escaping ((_ section: SectionData, _ index: Int) -> ())) {
        insertSectionOnView = completion
    }
    
    func insertRow(_ completion: @escaping (_ row: Row,_ indexPath: IndexPath) -> ()) {
        insertItemOnView = completion
    }
    
    func moveSection(_ completion: @escaping ((_ index: Int, _ newIndex: Int) -> ())) {
        moveSectionOnView = completion
    }
}

extension ITableViewDinamicUpdating {
    
    func insertSectionData(_ sectionData: SectionData, atNewIndex index: Int) {
        dataSourceAll.insert(sectionData, at: index)
        
        guard let newIndex = dataSourceForView.firstIndex(where: { $0 == sectionData }) else { return }
        insertSectionOnView(sectionData, newIndex)
    }
    
    func appendSectionData(_ sectionData: SectionData) {
        dataSourceAll.append(sectionData)
        insertSectionOnView(sectionData, 0)
    }
    
    func appendRow(_ row: Row, at newIndexPath: IndexPath?) {
        
        guard let indexPath = newIndexPath else { return }
        let indexSection = indexPath.section
        
        let sectionData = getSectionData(forIndex: indexSection)
        let section = sectionData.section
        
        let isFirstElementInSection = sectionData.isEmpty
        
        insertRow(row: row, at: indexPath)
        
//        guard let activeSectionIndex = getIndexSectionForView(forSection: section)  else { fatalError() }
        
        if isFirstElementInSection && sectionData.isActive {
            insertSectionOnView(sectionData, indexPath.section)
        }
        
        guard let indexPathInAсtive = getIndexPathForView(forRow: row) else { return }
        insertItemOnView(row, indexPathInAсtive)
    }
    
    func removeSection(_ sectionData: SectionData) {
        let section = sectionData.section
        guard let index = getIndexSection(forSection: sectionData.section) else { return }
        if sectionData.isActive {
            if let index = getIndexForView(forSection: section) {
                removeSectionOnView(index)
            }
        }
        dataSourceAll.remove(at: index)
    }
    
    func removeRow(_ row: Row) {
        guard let indexPath = getIndexPath(forRow: row) else { return }
        var sectionData: SectionData { getSectionData(forIndex: indexPath.section) }
        var section: Section { sectionData.section }
        
        if sectionData.isActive {
            guard let indexPath = getIndexPathForView(forRow: row) else { return }
            removeRowOnView(indexPath)
        }
        //TODO: -
        guard let index = getIndexSectionForView(forSection: section) else { return }
        dataSourceAll[indexPath.section].rows.remove(at: indexPath.row)
        
        if !sectionData.isActive {
            removeSectionOnView(index)
        }
    }
    
     func moveSectionData(_ sectionData: SectionData, from index: Int, to newIndex: Int) {
       
         let section = sectionData.section
         var activeIndex = getIndexForView(forSection: section)
         dataSourceAll.remove(at: index)
         dataSourceAll.insert(sectionData, at: newIndex)
         
         let activeNewIndex =  getIndexForView(forSection: section)
         
         let sectionIsActive = sectionData.isActive
         
         if let activeIndex = activeIndex, let activeNewIndex = activeNewIndex {
             if sectionIsActive, activeIndex != activeNewIndex {
                 moveSectionOnView(activeIndex, activeNewIndex)
             }
         }
     }
    
    func remove() {
        
    }
}
