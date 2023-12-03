////
////  Test.swift
////  Podcasts
////
////  Created by Anton on 03.12.2023.
////
//
//import UIKit
//
////MARK: - ITableViewDinamicUpdating
//protocol IViewModelDinamicUpdating: ITableViewModel {
//    //    typealias Row = SectionData.Row
//    //    typealias Section = SectionData.Section
//    var timeInterval: TimeInterval { get }
//    var dataSourceAll: [SectionData] { get set }
//    var removeSectionOnView: ((_ index: Int                                   ) -> ()) { get set }
//    var removeRowOnView:     ((_ indexPath: IndexPath                         ) -> ()) { get set }
//    var insertSectionOnView: ((_ section: Section, _ index: Int               ) -> ()) { get set }
//    var insertItemOnView:    ((_ item: Row,            _ indexPath: IndexPath ) -> ()) { get set }
//    var moveSectionOnView:   ((_ index: Int,           _ newIndex: Int        ) -> ()) { get set }
//    var reloadSection:       ((_ index: Int                                   ) -> ()) { get set }
//    
//    func update(dataSource: [SectionData])
//    
//    func update(by: [SectionData])
//}
//
//extension IViewModelDinamicUpdating {
//    
//    var timeInterval: TimeInterval {
//        return 0
//    }
//    
//    func update(dataSource: [SectionData]) {
//        update(by: dataSource)
//    }
//    
//    func removeSection(_ completion: @escaping (_ index: Int) -> ()) {
//        self.removeSectionOnView = completion
//    }
//    
//    func removeRow(_ completion: @escaping ((_ indexPath: IndexPath) -> ())) {
//        self.removeRowOnView = completion
//    }
//    
//    func insertSection(_ completion: @escaping ((_ section: Section, _ index: Int) -> ())) {
//        self.insertSectionOnView = completion
//    }
//    
//    func insertRow(_ completion: @escaping (_ row: Row,_ indexPath: IndexPath) -> ()) {
//        self.insertItemOnView = completion
//    }
//    
//    func moveSection(_ completion: @escaping ((_ index: Int, _ newIndex: Int) -> ())) {
//        moveSectionOnView = completion
//    }
//}
//
//extension IViewModelDinamicUpdating {
//    
//    func update(by newDataSource: [SectionData]) {
//        let oldDataSource = dataSourceAll
//        
//        DispatchQueue.global(qos: .background).async { [weak self] in
//            guard let self = self else { return }
//            
//            ///remove
//            oldDataSource.reversed().forEach { oldSectionData in
//                
//                if !newDataSource.contains(oldSectionData) {
//                    self.removeSectionData(oldSectionData)
//                } else {
//                    let oldRows = oldSectionData.rows
//                    oldRows.forEach { oldRow in
//                        newDataSource.forEach { newSection in
//                            if newSection.section == oldSectionData.section {
//                                let newRows = newSection.rows
//                                if !newRows.contains(oldRow) {
//                                    self.removeRow(oldRow)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            
//            /// append
//            newDataSource.enumerated { [weak self] indexNewSection, newSectionData in
//                guard let self = self else { return }
//                
//                let newSection = newSectionData.section
//                
//                if !dataSourceAll.contains(where: { $0.section == newSection }) {
//                    appendSectionData(newSectionData, atNewIndex: indexNewSection)
//                } else {
//                    newSectionData.rows.enumerated { [weak self] indexNewRow, newRow in
//                        guard let self = self else { return }
//                        
//                        dataSourceAll.forEach { [weak self] oldSectionData in
//                            guard let self = self else { return }
//                            
//                            if newSection == oldSectionData.section {
//                                if !oldSectionData.rows.contains(where: { $0 == newRow }) {
//                                    appendRow(newRow, toSectionData: oldSectionData)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//extension IViewModelDinamicUpdating {
//    
//    //MARK: SectionData
//    /// -----------------------------------------------------------------------------------------------------------------------------
//    /// Activate
//    func activateSectionData(_ sectionData: SectionData) {
//        DispatchQueue.global(qos: .background).async { [weak self] in
//            guard let self = self else { return }
//            
//            guard !sectionData.isActive else { fatalError() }
//            let section = sectionData.section
//            
//            guard let index = getIndexSection(forSection: section) else { return }
//            dataSourceAll[index].isActive = true
//            
//            guard dataSourceAll[index].isAvailable else { return }
//            let availableIndex = getIndexOfActiveSectionForView(sectionData: sectionData)
//            
//            
//            DispatchQueue.main.sync { [weak self] in
//                guard let self = self else { return }
//                
//                dataSourceForView.insert(sectionData, at: availableIndex)
//                guard let availableIndex = getIndexSectionForView(forSection: sectionData.section) else { return }
//                insertSectionOnView(sectionData.section, index)
//            }
//            
//            
//            sectionData.rows.enumerated { [weak self] indexRow, row in
//                guard let self = self else { return }
//                Thread.sleep(forTimeInterval: timeInterval)
//                
//                DispatchQueue.main.sync { [weak self] in
//                    guard let self = self else { return }
//                    
//                    insertItemOnView(row, IndexPath(row: indexRow, section: availableIndex))
//                    (self as? INotifyOnChanged)?.changed.raise()
//                }
//            }
//        }
//    }
//    
//    /// Deactivate
//    func deactivateSectionData(_ sectionData: SectionData) {
//        
//        DispatchQueue.global(qos: .background).async { [weak self] in
//            guard let self = self else { return }
//            
//            let section = sectionData.section
//            guard let index = getIndexSection(forSection: section) else { return }
//            dataSourceAll[index].isActive = false
//            print("print 3 \(dataSourceAll[index].isActive)")
//            guard let indexSection = getIndexSectionForView(forSection: section) else { return }
//            
//            sectionData.rows.indices.reversed().forEach { [weak self] rowIndex in
//                guard let self = self else { return }
//                Thread.sleep(forTimeInterval: 0.2)
//                DispatchQueue.main.sync {
//                    self.removeRowOnView(IndexPath(row: rowIndex, section: indexSection))
//                    self.dataSourceForView[indexSection].rows.remove(at: rowIndex)
//                    (self as? INotifyOnChanged)?.changed.raise()
//                }
//                
//            }
//            
//            DispatchQueue.main.sync {
//                self.removeSectionOnView(indexSection)
//                self.dataSourceForView.remove(at: indexSection)
//                (self as? INotifyOnChanged)?.changed.raise()
//            }
//        }
//    }
//    
//    /// -----------------------------------------------------------------------------------------------------------------------------
//    /// Remove
//    func removeSectionData(_ sectionData: SectionData) {
//        
//        let block = { [weak self] in
//            guard let self = self else { return }
//            
//            let section = sectionData.section
//            guard let index = getIndexSection(forSection: section) else { return }
//            if let index = getIndexSectionForView(forSection: section) {
//                dataSourceForView[index].rows.reversed().forEach { row in
//                    self.removeRow(row)
//                }
//            } else {
//                dataSourceAll.remove(at: index)
//            }
//        }
//        
//        if Thread.isMainThread {
//            DispatchQueue.global(qos: .background).async { [weak self] in
//                guard let self = self else { return }
//                block()
//            }
//        } else {
//            block()
//        }
//    }
//    
//    /// Append
//    func appendSectionData(_ sectionData: SectionData, atNewIndex index: Int) {
//        
//        let block = { [weak self] in
//            guard let self = self else { return }
//            
//            if !dataSourceAll.contains(where: { $0 == sectionData }) {
//                if !dataSourceAll.isEmpty, dataSourceAll.count != index {
//                    dataSourceAll.insert(sectionData, at: index)
//                } else {
//                    dataSourceAll.append(sectionData)
//                }
//            }
//            
//            guard sectionData.isAvailable else { return }
//            let indexSection = getIndexOfActiveSectionForView(sectionData: sectionData)
//            
//            DispatchQueue.main.sync { [weak self] in
//                guard let self = self else { return }
//                
//                if !dataSourceForView.isEmpty, dataSourceForView.count != indexSection {
//                    dataSourceForView.insert(sectionData, at: indexSection)
//                } else {
//                    dataSourceForView.append(sectionData)
//                }
//                insertSectionOnView(sectionData.section, indexSection)
//            }
//            
//            sectionData.rows.enumerated { [weak self] (indexRow, row) in
//                guard let self = self else { return }
//                
//                Thread.sleep(forTimeInterval: timeInterval)
//                DispatchQueue.main.async { [weak self] in
//                    guard let self = self else { return }
//                    
//                    insertItemOnView(row, IndexPath(row: indexRow, section: indexSection))
//                    (self as? INotifyOnChanged)?.changed.raise()
//                }
//            }
//        }
//        
//        if Thread.isMainThread {
//            DispatchQueue.global(qos: .background).async { [weak self] in
//                guard let self = self else { return }
//                block()
//            }
//        } else {
//            block()
//        }
//        
//    }
//    /// Move
//    func moveSectionData(_ sectionData: SectionData, from index: Int, to newIndex: Int) {
//        
//        dataSourceAll.remove(at: index)
//        dataSourceAll.insert(sectionData, at: newIndex)
//        
//        guard sectionData.isAvailable else { return }
//        let section = sectionData.section
//        
//        guard let activeIndex = getIndexSectionForView(forSection: section) else { return }
//        dataSourceForView = dataSourceAll.filter { $0.isAvailable }
//        guard let activeNewIndex = getIndexSectionForView(forSection: section), activeIndex != activeNewIndex else { return }
//        moveSectionOnView(activeIndex, activeNewIndex)
//    }
//    
//    //MARK: Row
//    /// -----------------------------------------------------------------------------------------------------------------------------
//    func appendRow(_ row: Row, toSectionData sectionData: SectionData) {
//        
//        let block = { [weak self] in
//            guard let self = self else { return }
//            
//            let indexRow = sectionData.rows.count == 0 ? 0 : (sectionData.rows.count - 1)
//            guard let indexSection = getIndexSection(forSection: sectionData.section) else { return }
//            
//            dataSourceAll[indexSection].rows.insert(row, at: indexRow)
//            
//            guard sectionData.isAvailable else { return }
//            let sectionIndex = getIndexOfActiveSectionForView(sectionData: sectionData)
//            
//            if !dataSourceForView.contains(where: { $0 == sectionData }) {
//                DispatchQueue.main.sync { [weak self] in
//                    guard let self = self else { return }
//                    
//                    if !dataSourceForView.isEmpty, dataSourceForView.count != sectionIndex {
//                        dataSourceForView.insert(sectionData, at: sectionIndex)
//                    } else {
//                        dataSourceForView.append(sectionData)
//                    }
//                    insertSectionOnView(sectionData.section, sectionIndex)
//                }
//            }
//            
//            Thread.sleep(forTimeInterval: timeInterval)
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                
//                if dataSourceForView[sectionIndex].rows.count == 0 {
//                    dataSourceForView[sectionIndex].rows.append(row)
//                } else {
//                    dataSourceForView[sectionIndex].rows.insert(row, at: indexRow)
//                }
//                let indexPath = IndexPath(row: indexRow, section: sectionIndex)
//                insertItemOnView(row, indexPath)
//            }
//        }
//        
//        if Thread.isMainThread {
//            DispatchQueue.global(qos: .background).async {
//                block()
//            }
//        } else {
//            block()
//        }
//    }
//    
//    func removeRow(_ row: Row) {
//        
//        let block = { [weak self] in
//            guard let self = self else { return }
//            
//            guard let indexPath = getIndexPath(forRow: row) else { return }
//            var sectionData: SectionData { getSectionData(forIndex: indexPath.section) }
//            var section: Section { sectionData.section }
//            dataSourceAll[indexPath.section].rows.remove(at: indexPath.row)
//            
//            if sectionData.isActive {
//                guard let indexPath = getIndexPathForView(forRow: row) else { return }
//                
//                DispatchQueue.main.sync { [weak self] in
//                    guard let self = self else { return }
//                    
//                    removeRowOnView(indexPath)
//                    dataSourceForView[indexPath.section].rows.remove(at: indexPath.row)
//                }
//            }
//            
//            if sectionData.isEmpty {
//                dataSourceAll.remove(at: indexPath.section)
//                guard let index = getIndexSectionForView(forSection: section) else { return }
//                
//                DispatchQueue.main.sync { [weak self] in
//                    guard let self = self else { return }
//                    
//                    dataSourceForView.remove(at: index)
//                    removeSectionOnView(index)
//                    (self as? INotifyOnChanged)?.changed.raise()
//                }
//            }
//        }
//        
//        if Thread.isMainThread {
//            DispatchQueue.global(qos: .background).async { in
//                block()
//            }
//        } else {
//            block()
//        }
//    }
//}
//
//
//extension IViewModelDinamicUpdating {
//    
//    func getIndexPath(forRow row: Row) -> IndexPath? {
//        for (indexSection, sectionData) in dataSourceAll.enumerated() {
//            for (indexRow, row1) in sectionData.rows.enumerated() {
//                if row == row1 {
//                    return IndexPath(row: indexRow, section: indexSection)
//                }
//            }
//        }
//        return nil
//    }
//    
//    func getIndexSection(forSection section: Section) -> Int? {
//        for (indexSection, sectionData) in dataSourceAll.enumerated() {
//            if sectionData.section == section {
//                return indexSection
//            }
//        }
//        return nil
//    }
//    
//    func getSectionData(forIndex index: Int) -> SectionData {
//        return dataSourceAll[index]
//    }
//    
//    func getIndexOfActiveSectionForView(sectionData: SectionData) -> Int {
//        var sectionIndex = 0
//        for value in dataSourceAll {
//            
//            if value.isAvailable && value.section != sectionData.section  {
//                sectionIndex += 1
//                continue
//            }
//            if value.section == sectionData.section {
//                return sectionIndex
//            }
//        }
//        return sectionIndex
//    }
//}
