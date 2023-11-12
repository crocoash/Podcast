//
//  ViewModelUpdating.swift
//  Podcasts
//
//  Created by Anton on 23.09.2023.
//

import UIKit

//MARK: - ITableViewDinamicUpdating
protocol IViewModelDinamicUpdating where Self: ITableViewModel {
//    typealias Row = SectionData.Row
//    typealias Section = SectionData.Section
    
    var dataSourceAll: [SectionData] { get set }
    var removeSectionOnView: ((_ index: Int                                   ) -> ()) { get set }
    var removeRowOnView:     ((_ indexPath: IndexPath                         ) -> ()) { get set }
    var insertSectionOnView: ((_ section: Section, _ index: Int               ) -> ()) { get set }
    var insertItemOnView:    ((_ item: Row,            _ indexPath: IndexPath ) -> ()) { get set }
    var moveSectionOnView:   ((_ index: Int,           _ newIndex: Int        ) -> ()) { get set }
    var reloadSection:       ((_ index: Int                                   ) -> ()) { get set }
    
    func configureDataSource()
    func update(dataSource: [SectionData])
    
    func update(by: [SectionData])
}

extension IViewModelDinamicUpdating {
    
    func update(dataSource: [SectionData]) {
        update(by: dataSource)
    }
    
    func removeSection(_ completion: @escaping (_ index: Int) -> ()) {
        removeSectionOnView = completion
    }
    
    func removeRow(_ completion: @escaping ((_ indexPath: IndexPath) -> ())) {
        removeRowOnView = completion
    }
    
    func insertSection(_ completion: @escaping ((_ section: Section, _ index: Int) -> ())) {
        insertSectionOnView = completion
    }
    
    func insertRow(_ completion: @escaping (_ row: Row,_ indexPath: IndexPath) -> ()) {
        insertItemOnView = completion
    }
    
    func moveSection(_ completion: @escaping ((_ index: Int, _ newIndex: Int) -> ())) {
        moveSectionOnView = completion
    }
}

extension IViewModelDinamicUpdating {
    
    func insertSectionData(_ sectionData: SectionData, atNewIndex index: Int) {
        dataSourceAll.insert(sectionData, at: index)
        if sectionData.isAvailable {
            dataSourceForView.insert(sectionData, at: index)
        }
        let section = sectionData.section
        guard let newIndex = getIndexSectionForView(forSection: section) else { return }
        insertSectionOnView(section, newIndex)
    }

    func update(by newDataSource: [SectionData]) {
        let oldDataSource = dataSourceAll
        
        ///check old data source
        oldDataSource.enumerated { indexSection, oldSectionData in
            let section = oldSectionData.section
            let newSections = newDataSource.map { $0.section }
            
            if newSections.isEmpty || !newSections.contains(section) {
                guard let index = getIndexSection(forSection: section) else { return }
                dataSourceAll.remove(at: index)
                guard let index = getIndexSectionForView(forSection: section) else { return }
                removeSectionOnView(index)
                dataSourceForView.remove(at: index)
            } else {
                for oldRow in oldSectionData.rows {
                    newDataSource.enumerated { newIndexSection, newSection in
                        if newSection.section == oldSectionData.section {
                            if let index = getIndexPath(forRow: oldRow)?.row {
                                dataSourceAll[indexSection].rows.remove(at: index)
                                removeRowOnView(IndexPath(item: index, section: indexSection))
                            }
                        }
                    }
                }
            }
//            
//                     if section.rows.isEmpty {
//                        playlist.remove(at: indexSection)
//                        removeSection(indexSection)
//                     }
        }
        
        /// append
        newDataSource.enumerated { indexNewSection, newSectionData in
            let newSection = newSectionData.section
            
            if !dataSourceAll.contains(where: { $0.section == newSection }) {
                
                if !dataSourceAll.isEmpty, dataSourceAll.count != indexNewSection {
                    insertSectionData(newSectionData, atNewIndex: indexNewSection)
                } else {
                    appendSectionData(newSectionData)
                }
            } else {
                newSectionData.rows.enumerated { indexNewRow, newRow in
                    
                    dataSourceAll.enumerated { indexSection, sectionData in
                        if newSection == sectionData.section {
                            if !sectionData.rows.contains(where: { $0 == newRow }) {
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
    
    private func insertRow(row: Row, at indexPath: IndexPath) {
        dataSourceAll[indexPath.section].rows.insert(row, at: indexPath.row)
    }
}

extension IViewModelDinamicUpdating {
    
    func getIndexForSectionForView(sectionData: SectionData) -> Int {
        var sectionIndex = 0
        for value in dataSourceAll {
            
            if !value.isAvailable {
                sectionIndex += 1
                continue
            }
            if value.section == sectionData.section {
                return sectionIndex
            }
        }
        return sectionIndex
    }
    
    func activateSectionData(_ sectionData: SectionData) {
        let section = sectionData.section
        
        guard let index = getIndexSection(forSection: section) else { return }
        dataSourceAll[index].isActive = true
        
        guard sectionData.isAvailable else { return }
        let availableIndex = getIndexForSectionForView(sectionData: sectionData)
        dataSourceForView.insert(sectionData, at: availableIndex)
        
        guard let index = getIndexSectionForView(forSection: sectionData.section) else { return }
        
        insertSectionOnView(sectionData.section, index)
        sectionData.rows.enumerated {
            insertItemOnView($1, IndexPath(row: $0, section: index))
        }
    }
    
    func deactivateSectionData(_ sectionData: SectionData) {
        let section = sectionData.section
        guard let index = getIndexSection(forSection: section) else { return }
        dataSourceAll[index].isActive = false
        
        guard let indexSection = getIndexSectionForView(forSection: section) else { return }
        sectionData.rows.indices.reversed().forEach {
            removeRowOnView(IndexPath(row: $0, section: indexSection))
        }
        removeSectionOnView(indexSection)
        dataSourceForView.remove(at: indexSection)
    }
    
    func removeSectionData(_ sectionData: SectionData) {
        
    }
    
    func appendSectionData(_ sectionData: SectionData) {
        dataSourceAll.append(sectionData)
        if sectionData.isAvailable {
            dataSourceForView.append(sectionData)
        }
        insertSectionOnView(sectionData.section, 0)
    }
    
    func appendRow(_ row: Row, at newIndexPath: IndexPath?) {
        
        guard let indexPath = newIndexPath else { return }
        let indexSection = indexPath.section
        
        let sectionData = getSectionData(forIndex: indexSection)
        let section = sectionData.section
        let isFirstElementInSection = sectionData.isEmpty
        
        insertRow(row: row, at: indexPath)
        
        if isFirstElementInSection && sectionData.isActive {
            let index = getIndexSectionForView(forSection: section)
            insertSectionOnView(section, index ?? 0)
        }
                
        guard let indexPathInAсtive = getIndexPathForView(forRow: row) else { return }
        insertItemOnView(row, indexPathInAсtive)
    }
    
    func removeRow(_ row: Row) {
        guard let indexPath = getIndexPath(forRow: row) else { return }
        var sectionData: SectionData { getSectionData(forIndex: indexPath.section) }
        var section: Section { sectionData.section }
        
        if sectionData.isActive {
            guard let indexPath = getIndexPathForView(forRow: row) else { return }
            removeRowOnView(indexPath)
        }
        guard let index = getIndexSectionForView(forSection: section) else { return }
        dataSourceAll[indexPath.section].rows.remove(at: indexPath.row)
        
        if !sectionData.isAvailable {
            removeSectionOnView(index)
        }
    }
    
     func moveSectionData(_ sectionData: SectionData, from index: Int, to newIndex: Int) {
       
         let section = sectionData.section
         var activeIndex = getIndexSectionForView(forSection: section)
         dataSourceAll.remove(at: index)
         dataSourceAll.insert(sectionData, at: newIndex)
         
         let activeNewIndex =  getIndexSectionForView(forSection: section)
         
         let sectionIsActive = sectionData.isActive
         
         if let activeIndex = activeIndex, let activeNewIndex = activeNewIndex {
             if sectionIsActive, activeIndex != activeNewIndex {
                 moveSectionOnView(activeIndex, activeNewIndex)
             }
         }
     }
    
//    func remove() {
//        
//    }
}


extension IViewModelDinamicUpdating {
    
     func getIndexPath(forRow row: Row) -> IndexPath? {
        for (indexSection, sectionData) in dataSourceAll.enumerated() {
            for (indexRow, row1) in sectionData.rows.enumerated() {
                if row == row1 {
                    return IndexPath(row: indexRow, section: indexSection)
                }
            }
        }
        return nil
    }
    
     func getIndexSection(forSection section: Section) -> Int? {
        for (indexSection, sectionData) in dataSourceAll.enumerated() {
            if sectionData.section == section {
                return indexSection
            }
        }
        return nil
    }
    
     func getSectionData(forIndex index: Int) -> SectionData {
        return dataSourceAll[index]
    }
}
