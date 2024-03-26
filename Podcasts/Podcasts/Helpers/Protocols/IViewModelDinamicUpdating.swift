//
//  ViewModelUpdating.swift
//  Podcasts
//
//  Created by Anton on 23.09.2023.
//

import UIKit

enum Direction {
    case straight
    case reveresed
}

//MARK: - ITableViewDinamicUpdating
protocol IViewModelDinamicUpdating: ITableViewModel {
    
    var updatingDelay: TimeInterval { get }
    var dataSourceAll: [SectionData] { get set }
    
    var removeSectionOnView: ((_ index    : Int                               ) async -> ()) { get set }
    var removeRowOnView:     ((_ indexPath: IndexPath                         ) async -> ()) { get set }
    var insertSectionOnView: ((_ section  : Section,   _ index    : Int       ) async -> ()) { get set }
    var insertItemOnView:    ((_ item     : Row,       _ indexPath: IndexPath ) async -> ()) { get set }
    var moveSectionOnView:   ((_ index    : Int,       _ newIndex : Int       ) async -> ()) { get set }
    var reloadSection:       ((_ index    : Int                               ) async -> ()) { get set }
    
    func update(by: [SectionData]) async
    var isUpdating: Bool { get set }
}

//MARK: - Public Methods

extension IViewModelDinamicUpdating {
    
    func removeSection(_ completion:  @escaping (_ index: Int) async -> ())  {
        removeSectionOnView = completion
    }
    
    func removeRow(_ completion: @escaping (_ indexPath: IndexPath) async -> ()) {
            removeRowOnView = completion
    }
    
    func insertSection(_ completion: @escaping (_ section: Section, _ index: Int) async -> ()) {
        insertSectionOnView = completion
    }
    
    func insertRow(_ completion: @escaping (_ row: Row, _ indexPath: IndexPath) async -> ()) {
        insertItemOnView = completion
    }
    
    func moveSection(_ completion: @escaping (_ index: Int, _ newIndex: Int) async -> ()) {
        moveSectionOnView = completion
    }
}

extension IViewModelDinamicUpdating {
    
//    func activateSectionData(_ sectionData: SectionData) {
//        Task { await activateSectionData1(sectionData) }
//    }
//    
//    func deactivateSectionData(_ sectionData: SectionData) {
//        Task { await deactivateSectionData1(sectionData) }
//    }
//    
//    func removeSectionData(_ sectionData: SectionData) {
//        Task { await removeSectionData1(sectionData) }
//    }
//    
//    func appendSectionData(_ sectionData: SectionData, atNewIndex index: Int) {
//        Task { await appendSectionData1(sectionData, atNewIndex: index) }
//    }
//    
//    func moveSectionData(_ sectionData: SectionData, from index: Int, to newIndex: Int) {
//        Task { await moveSectionData1(sectionData, from: index, to: newIndex) }
//    }
//    
//    func appendRow(_ row: Row, toSectionData sectionData: SectionData) {
//        Task { await appendRow1(row, toSectionData: sectionData) }
//    }
//    
//    func removeRow(_ row: Row, atSectionIndex sectionIndex: Int) {
//        Task { await removeRow1(row, atSectionIndex: sectionIndex) }
//    }
}

//MARK: - Private Methods
extension IViewModelDinamicUpdating {
    
     func update(by newDataSource: [SectionData]) async {
        
        let oldDataSource = dataSourceAll
        
        isUpdating = true
        (self as? INotifyOnChanged)?.changed.raise()
        ///remove
        for oldSectionData in oldDataSource/*.reversed()*/ {

            if !newDataSource.contains(where: { $0.section == oldSectionData.section }) {
                await removeSectionData(oldSectionData)
            } else {
                let oldRows = oldSectionData.rows
                for oldRow in oldRows {
                    for newSection in newDataSource {
                        if newSection.section == oldSectionData.section {
                            let newRows = newSection.rows
                            if !newRows.contains(oldRow) {
                                guard let index = await getIndexSection(forSection: oldSectionData.section) else { return }
                                await self.removeRow(oldRow, atSectionIndex: index)
                            }
                        }
                    }
                }
            }
        }
        
        /// append
        for (indexNewSection, newSectionData) in newDataSource.enumerated() {
            let newSection = newSectionData.section
            
            if !dataSourceAll.contains(where: { $0.section == newSection }) {
                await appendSectionData(newSectionData, atNewIndex: indexNewSection, direction: .straight)
            } else {
                for newRow in newSectionData.rows {
                    for oldSectionData in dataSourceAll {
                        
                        if newSection == oldSectionData.section {
                            if !oldSectionData.rows.contains(where: { $0 == newRow }) {
                                await appendRow(newRow, toSectionData: oldSectionData)
                            }
                        }
                    }
                }
            }
        }
         isUpdating = false
        (self as? INotifyOnChanged)?.changed.raise()
    }
    
    //MARK: SectionData
    /// -----------------------------------------------------------------------------------------------------------------------------
    /// Activate
     func activateSectionData(_ sectionData: SectionData) async {
        isUpdating = true
        (self as? INotifyOnChanged)?.changed.raise()
        
        let section = sectionData.section
        
        guard let index = await getIndexSection(forSection: section) else { return }
        await dataSourceAll[index].changeActiveState(newValue: true)
        
        guard dataSourceAll[index].isAvailable else { return }
        let availableIndex = await getIndexOfActiveSectionForView(sectionData: sectionData)
        dataSourceForView.insert(sectionData, at: availableIndex)
        
        guard let index = getIndexSectionForView(forSection: sectionData.section) else { return }
        await insertSectionOnView(sectionData.section, index)
        
        await sectionData.rows.enumerated { [weak self] indexRow, row in
            guard let self = self else { return }
            
            await insertItemOnView(row, IndexPath(row: indexRow, section: index))
            (self as? INotifyOnChanged)?.changed.raise()
            
        }
        isUpdating = false
        (self as? INotifyOnChanged)?.changed.raise()
    }
    /// Deactivate
     func deactivateSectionData(_ sectionData: SectionData) async {
        
        isUpdating = true
        (self as? INotifyOnChanged)?.changed.raise()
        
        let section = sectionData.section
        guard let index = await getIndexSection(forSection: section) else { return }
        await dataSourceAll[index].changeActiveState(newValue: false)
        
        guard let indexSection = getIndexSectionForView(forSection: section) else { return }
        await sectionData.rows.indices.reversed().forEach {  rowIndex in
            
            await removeRowOnView(IndexPath(row: rowIndex, section: indexSection))
            await removeSectionOnView(indexSection)
            
        }
        
        dataSourceForView.remove(at: indexSection)
        isUpdating = false
        (self as? INotifyOnChanged)?.changed.raise()
        
    }
    
    /// Remove
     func removeSectionData(_ sectionData: SectionData) async {
        
        let section = sectionData.section
        guard let index = await getIndexSection(forSection: section) else { return }
        
        if let _ = getIndexSectionForView(forSection: section) {
            await sectionData.rows/*.reversed()*/.forEach { [weak self] row in
                guard let self = self else { return }
                await removeRow(row, atSectionIndex: index)
            }
        } else {
            dataSourceAll.remove(at: index)
        }
    }
    
    /// Append
     func appendSectionData(_ sectionData: SectionData, atNewIndex index: Int, direction: Direction ) async {
        if sectionData.rows.isEmpty {
            dataSourceAll.append(sectionData)
        } else {
            switch direction {
            case .reveresed:
                for row in sectionData.rows {
                    await appendRow(row, toSectionData: sectionData)
                }
            case .straight:
                for row in sectionData.rows {
                    await appendRow(row, toSectionData: sectionData)
                }
                
            }
            
        }
    }
    
    /// Move
     func moveSectionData(_ sectionData: SectionData, from index: Int, to newIndex: Int) async {
        guard let index1 = await getIndexSection(forSection: sectionData.section) else { return }
        
        dataSourceAll.remove(at: index1)
        dataSourceAll.insert(sectionData, at: newIndex)
        
        let section = sectionData.section
        
        guard let activeIndex = getIndexSectionForView(forSection: section) else { return }
        dataSourceForView = dataSourceAll.filter { $0.isAvailable }
        guard let activeNewIndex = getIndexSectionForView(forSection: section), activeIndex != activeNewIndex else { return }
        
        await moveSectionOnView(activeIndex, activeNewIndex)
    }
    
    //MARK: Row
    /// -----------------------------------------------------------------------------------------------------------------------------
     func appendRow(_ row: Row, toSectionData sectionData: SectionData) async {
        
        if !dataSourceAll.contains(where: { $0 == sectionData }) {
            var sectionData1 = sectionData
            await sectionData1.removeAllRows()
            dataSourceAll.append(sectionData1)
        }
        
        guard let indexSection = await getIndexSection(forSection: sectionData.section) else { return }
        
        await dataSourceAll[indexSection].appendNewRow(row)
        
        ///check if section is actual for view
        guard dataSourceAll[indexSection].isAvailable else { return }
        
        var sectionIndex = await getIndexOfActiveSectionForView(sectionData: sectionData)
        
        if !dataSourceForView.contains(where: { $0.section == sectionData.section }) {
            var sectionData1 = sectionData
            await sectionData1.removeAllRows()
            dataSourceForView.append(sectionData1)
            sectionIndex = dataSourceForView.count - 1
            await insertSectionOnView(sectionData.section, dataSourceForView.count - 1)
            (self as? INotifyOnChanged)?.changed.raise() // MARK: -
        }
        await dataSourceForView[sectionIndex].appendNewRow(row)
        
        let countOfRows = dataSourceForView[sectionIndex].rows.count
        let indexRow = countOfRows == 0 ? 0 : countOfRows - 1
        let indexPath = IndexPath(row: indexRow, section: sectionIndex)
        
        await insertItemOnView(row, indexPath)
        (self as? INotifyOnChanged)?.changed.raise()
    }
    
    func removeRow(_ row: Row, atSectionIndex sectionIndex: Int) async {
        guard let index = await getIndexPath(forRow: row, atSection: sectionIndex) else { return }
        await dataSourceAll[sectionIndex].removeRow(atIndex: index)
        let sectionData: SectionData = await getSectionData(forIndex: sectionIndex)
        let section: Section = sectionData.section
        
        if sectionData.isActive {
            guard let indexPath = await getIndexPathOfRowForView(forRow: row, inSection: section) else { return }
            
            await dataSourceForView[indexPath.section].removeRow(atIndex: indexPath.row)
            try? await Task.sleep(nanoseconds: 50_000_000 )
            await removeRowOnView(indexPath)
            (self as? INotifyOnChanged)?.changed.raise()
        }
        
        if dataSourceAll[sectionIndex].isEmpty {
            guard let index = getIndexSectionForView(forSection: section) else { return }
            dataSourceAll.remove(at: sectionIndex)
            dataSourceForView.remove(at: index)
            await removeSectionOnView(index)
        }
    }
}

extension IViewModelDinamicUpdating {
    
    @inlinable
    func getIndexPath(forRow row: Row, atSection index: Int) async -> Int? {
        //        for (indexSection, sectionData) in dataSourceAll.enumerated() {
        //            for (indexRow, row1) in sectionData.rows.enumerated() {
        //                if row == row1 {
        //                    return IndexPath(row: indexRow, section: indexSection)
        //                }
        //            }
        //        }
        //        return nil
        for (index, row1) in dataSourceAll[index].rows.enumerated() {
            if row == row1 {
                return index
            }
        }
        return nil
    }
    
    @inlinable
    func getIndexSection(forSection section: Section) async -> Int? {
        
        for (indexSection, sectionData) in dataSourceAll.enumerated() {
            if sectionData.section == section {
                return indexSection
            }
        }
        return nil
    }
    
    @inlinable
    func getSectionData(forIndex index: Int) async -> SectionData {
        return dataSourceAll[index]
    }
    
    @inlinable
    func getIndexOfActiveSectionForView(sectionData: SectionData) async -> Int {
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
