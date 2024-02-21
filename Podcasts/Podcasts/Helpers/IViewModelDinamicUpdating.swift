//
//  ViewModelUpdating.swift
//  Podcasts
//
//  Created by Anton on 23.09.2023.
//

import UIKit

//MARK: - ITableViewDinamicUpdating
protocol IViewModelDinamicUpdating: ITableViewModel {

    
    var updatingDelay: TimeInterval { get }
    var dataSourceAll: [SectionData] { get set }
    
    var removeSectionOnView: ( (_ index    : Int                               )  -> ()) { get set }
    var removeRowOnView:     ((_ indexPath: IndexPath                         )  -> ()) { get set }
    var insertSectionOnView: ((_ section  : Section,   _ index    : Int       )  -> ()) { get set }
    var insertItemOnView:    ((_ item     : Row,       _ indexPath: IndexPath )  -> ()) { get set }
    var moveSectionOnView:   ((_ index    : Int,       _ newIndex : Int       )  -> ()) { get set }
    var reloadSection:       ((_ index    : Int                               )  -> ()) { get set }
    
    func update(dataSource: [SectionData])
    
    func update(by: [SectionData])
    var isUpdating: Bool { get set }
}

extension IViewModelDinamicUpdating {
    
    func update(dataSource: [SectionData]) {
        update(by: dataSource)
    }
    
   func removeSection(_ completion: @escaping (_ index: Int) -> ())  {
       removeSectionOnView = completion
    }
    
   func removeRow(_ completion: @escaping (_ indexPath: IndexPath) -> ()) {
        removeRowOnView = completion
    }
    
    func insertSection(_ completion: @escaping (_ section: Section, _ index: Int) -> ()) {
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
        
        
        isUpdating = true
        (self as? INotifyOnChanged)?.changed.raise()
        ///remove
        oldDataSource.reversed().forEach { [weak self] oldSectionData in
            guard let self = self else { return }
            
            if !newDataSource.contains(oldSectionData) {
                removeSectionData(oldSectionData)
            } else {
                let oldRows = oldSectionData.rows
                oldRows.forEach { oldRow in
                    
                    newDataSource.forEach { [weak self] newSection in
                        guard let self = self else { return }
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
        newDataSource.enumerated { [weak self] indexNewSection, newSectionData in
            guard let self = self else { return }
            
            let newSection = newSectionData.section
            
            if !dataSourceAll.contains(where: { $0.section == newSection }) {
                appendSectionData(newSectionData, atNewIndex: indexNewSection)
            } else {
                newSectionData.rows.enumerated { [weak self] indexNewRow, newRow in
                    guard let self = self else { return }
                    
                    dataSourceAll.forEach { [weak self] oldSectionData in
                        guard let self = self else { return }
                        
                        if newSection == oldSectionData.section {
                            if !oldSectionData.rows.contains(where: { $0 == newRow }) {
                                appendRow(newRow, toSectionData: oldSectionData)
                            }
                        }
                    }
                }
            }
            //
            isUpdating = false
            (self as? INotifyOnChanged)?.changed.raise()
        }
    }
}

extension IViewModelDinamicUpdating {
    
    //MARK: SectionData
    /// -----------------------------------------------------------------------------------------------------------------------------
    /// Activate
    func activateSectionData(_ sectionData: SectionData) {
        isUpdating = true
        (self as? INotifyOnChanged)?.changed.raise()
        
        let section = sectionData.section
        
        guard let index = getIndexSection(forSection: section) else { return }
        dataSourceAll[index].isActive = true
        
        guard dataSourceAll[index].isAvailable else { return }
        let availableIndex = getIndexOfActiveSectionForView(sectionData: sectionData)
        dataSourceForView.insert(sectionData, at: availableIndex)
        
        guard let index = getIndexSectionForView(forSection: sectionData.section) else { return }
        
        insertSectionOnView(sectionData.section, index)
        
        sectionData.rows.enumerated { [weak self] indexRow, row in
            guard let self = self else { return }
            
            insertItemOnView(row, IndexPath(row: indexRow, section: index))
            (self as? INotifyOnChanged)?.changed.raise()
            
        }
        isUpdating = false
        (self as? INotifyOnChanged)?.changed.raise()
    }
    /// Deactivate
    func deactivateSectionData(_ sectionData: SectionData) {
        
        isUpdating = true
        (self as? INotifyOnChanged)?.changed.raise()
        
        let section = sectionData.section
        guard let index = getIndexSection(forSection: section) else { return }
        dataSourceAll[index].isActive = false
        
        guard let indexSection = getIndexSectionForView(forSection: section) else { return }
        sectionData.rows.indices.reversed().forEach { [weak self] rowIndex in
            guard let self = self else { return }
            
            removeRowOnView(IndexPath(row: rowIndex, section: indexSection))
        }
        
        removeSectionOnView(indexSection)
        dataSourceForView.remove(at: indexSection)
        isUpdating = false
        (self as? INotifyOnChanged)?.changed.raise()
        
    }
    
    /// -----------------------------------------------------------------------------------------------------------------------------
    /// Remove
    func removeSectionData(_ sectionData: SectionData) {
        
        let section = sectionData.section
        guard let index = getIndexSection(forSection: section) else { return }
        if getIndexSectionForView(forSection: section) != nil {
            sectionData.rows.reversed().forEach { [weak self] row in
                guard let self = self else { return }
                removeRow(row)
            }
        } else {
            dataSourceAll.remove(at: index)
        }
    }
    
    /// Append
    func appendSectionData(_ sectionData: SectionData, atNewIndex index: Int) {
        if sectionData.rows.isEmpty {
            dataSourceAll.append(sectionData)
        } else {
            sectionData.rows.forEach {
                appendRow($0, toSectionData: sectionData)
            }
        }
    }
    
    /// Move
    func moveSectionData(_ sectionData: SectionData, from index: Int, to newIndex: Int) {
        guard let index1 = getIndexSection(forSection: sectionData.section) else { return }
        
        dataSourceAll.remove(at: index1)
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
            insertSectionOnView(sectionData.section, dataSourceForView.count - 1)
        }
        
        dataSourceForView[sectionIndex].rows.append(row)
        
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
            
            self.dataSourceForView[indexPath.section].rows.remove(at: indexPath.row)
            
            self.removeRowOnView(indexPath)
            (self as? INotifyOnChanged)?.changed.raise()
        }
        
        if sectionData.isEmpty {
            guard let index = getIndexSectionForView(forSection: section) else { return }
            dataSourceAll.remove(at: indexPath.section)
            dataSourceForView.remove(at: index)
            
            removeSectionOnView(index)
        }
    }
}



extension IViewModelDinamicUpdating {
    
    @inlinable func getIndexPath(forRow row: Row) -> IndexPath? {
        for (indexSection, sectionData) in dataSourceAll.enumerated() {
            for (indexRow, row1) in sectionData.rows.enumerated() {
                if row == row1 {
                    return IndexPath(row: indexRow, section: indexSection)
                }
            }
        }
        return nil
    }
    
    @inlinable func getIndexSection(forSection section: Section)  -> Int? {
        for (indexSection, sectionData) in dataSourceAll.enumerated() {
            if sectionData.section == section {
                return indexSection
            }
        }
        return nil
    }
    
    @inlinable func getSectionData(forIndex index: Int)  -> SectionData {
        return dataSourceAll[index]
    }
    
    @inlinable func getIndexOfActiveSectionForView(sectionData: SectionData)  -> Int {
        var sectionIndex = 0
        
        for value in dataSourceAll {
            
            if let sectionData1 =  dataSourceForView.first(where: { $0.section == sectionData.section }), sectionData1.isEmpty || value.isAvailable {
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
