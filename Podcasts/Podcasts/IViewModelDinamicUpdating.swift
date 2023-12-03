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

    func update(by newDataSource: [SectionData]) {
        let oldDataSource = dataSourceAll
        
        ///remove
        oldDataSource.reversed().forEach { oldSectionData in
                
            if !newDataSource.contains(oldSectionData) {
                removeSectionData(oldSectionData)
            } else {
                let oldRows = oldSectionData.rows
                oldRows.forEach { oldRow in
                    newDataSource.forEach { newSection in
                        if newSection.section == oldSectionData.section {
                            let newRows = newSection.rows
                            if !newRows.contains(oldRow) {
                                removeRow(oldRow)
                            }
                        }
                    }
                }
            }
        }
        
        /// append
        newDataSource.enumerated { indexNewSection, newSectionData in
            let newSection = newSectionData.section
            
            if !dataSourceAll.contains(where: { $0.section == newSection }) {
                appendSectionData(newSectionData, atNewIndex: indexNewSection)
            } else {
                newSectionData.rows.enumerated { indexNewRow, newRow in
                    
                    dataSourceAll.forEach { oldSectionData in
                        if newSection == oldSectionData.section {
                            if !oldSectionData.rows.contains(where: { $0 == newRow }) {
                                appendRow(newRow, toSectionData: oldSectionData)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension IViewModelDinamicUpdating {
    
    //MARK: SectionData
    /// -----------------------------------------------------------------------------------------------------------------------------
    /// Activate
    func activateSectionData(_ sectionData: SectionData) {
        let section = sectionData.section
        
        guard let index = getIndexSection(forSection: section) else { return }
        dataSourceAll[index].isActive = true
        
        guard sectionData.isAvailable else { return }
        let availableIndex = getIndexOfActiveSectionForView(sectionData: sectionData)
        dataSourceForView.insert(sectionData, at: availableIndex)
        
        guard let index = getIndexSectionForView(forSection: sectionData.section) else { return }
        
        insertSectionOnView(sectionData.section, index)
        sectionData.rows.enumerated {
            insertItemOnView($1, IndexPath(row: $0, section: index))
        }
    }
    /// Deactivate
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
       
    /// -----------------------------------------------------------------------------------------------------------------------------
    /// Remove
    func removeSectionData(_ sectionData: SectionData) {
        let section = sectionData.section
        
        guard let index = getIndexSection(forSection: section) else { return }
        if let index = getIndexSectionForView(forSection: section) {
            sectionData.rows.reversed().forEach { row in
                removeRow(row)
            }
        } else {
            dataSourceAll.remove(at: index)
        }
    }

    /// Append
    func appendSectionData(_ sectionData: SectionData, atNewIndex index: Int) {
        sectionData.rows.forEach {
            appendRow($0, toSectionData: sectionData)
        }
    }
    
    /// Move
    func moveSectionData(_ sectionData: SectionData, from index: Int, to newIndex: Int) {
      
        dataSourceAll.remove(at: index)
        dataSourceAll.insert(sectionData, at: newIndex)
        
        guard sectionData.isAvailable else { return }
        let section = sectionData.section
  
        guard let activeIndex = getIndexSectionForView(forSection: section) else { return }
        dataSourceForView = dataSourceAll.filter { $0.isAvailable }
        guard let activeNewIndex = getIndexSectionForView(forSection: section), activeIndex != activeNewIndex else { return }
        moveSectionOnView(activeIndex, activeNewIndex)
    }
       
    //MARK: Row
    /// -----------------------------------------------------------------------------------------------------------------------------
    func appendRow(_ row: Row, toSectionData sectionData: SectionData) {
        
        if !dataSourceAll.contains(where: { $0 == sectionData }) {
            var sectionData1 = sectionData
            sectionData1.rows.removeAll()
            dataSourceAll.append(sectionData1)
        }
        
        guard let indexSection = getIndexSection(forSection: sectionData.section) else { return }
        
        dataSourceAll[indexSection].rows.append(row)
        
        ///check if section is actual for view
        guard dataSourceAll[indexSection].isAvailable else { return }
        
        var sectionIndex = getIndexOfActiveSectionForView(sectionData: sectionData)

        if !dataSourceForView.contains(where: { $0.section == sectionData.section }) {
            var sectionData1 = sectionData
            sectionData1.rows.removeAll()
            dataSourceForView.append(sectionData1)
            sectionIndex = dataSourceForView.count - 1
            dataSourceForView[sectionIndex].rows.append(row)
            insertSectionOnView(sectionData.section, sectionIndex)
        } else {
            dataSourceForView[sectionIndex].rows.append(row)
        }
        
        let indexRow = dataSourceForView[sectionIndex].rows.count == 0 ? 0 : dataSourceForView[sectionIndex].rows.count - 1
        let indexPath = IndexPath(row: indexRow, section: sectionIndex)
        insertItemOnView(row, indexPath)
        (self as? INotifyOnChanged)?.changed.raise()
    }
    
    func removeRow(_ row: Row) {
        guard let indexPath = getIndexPath(forRow: row) else { return }
        var sectionData: SectionData { getSectionData(forIndex: indexPath.section) }
        var section: Section { sectionData.section }
        dataSourceAll[indexPath.section].rows.remove(at: indexPath.row)

        if sectionData.isActive {
            guard let indexPath = getIndexPathForView(forRow: row) else { return }
            removeRowOnView(indexPath)
            dataSourceForView[indexPath.section].rows.remove(at: indexPath.row)
        }
     
        if sectionData.isEmpty {
            guard let index = getIndexSectionForView(forSection: section) else { return }
            dataSourceAll.remove(at: indexPath.section)
            removeSectionOnView(index)
            dataSourceForView.remove(at: index)
            (self as? INotifyOnChanged)?.changed.raise()
        }
    }
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
    
    func getIndexOfActiveSectionForView(sectionData: SectionData) -> Int {
        var sectionIndex = 0
        
        for value in dataSourceAll {
            
            if let sectionData1 = dataSourceForView.first(where: { $0.section == sectionData.section }), sectionData1.isEmpty || value.isAvailable {
                if value.section != sectionData.section {
                    sectionIndex += 1
                    continue
                }
            }
            
            if value.section == sectionData.section {
                return sectionIndex
            }
        }
        return sectionIndex
    }
}
