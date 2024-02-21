//
//  ITableViewSearched.swift
//  Podcasts
//
//  Created by Anton on 06.11.2023.
//

import Foundation

//MARK: - Searched
protocol ITableViewSearched where Self: IViewModelDinamicUpdating, SectionData: ISearchedSectionData {
    var searchedSectionData: SectionData? { get set }
    var searchedText: String? { get set } 
    
    func performSearch(_ text: String?)
}

extension ITableViewSearched {
    
    func cancelSearching() {
        if let searchedSectionData = searchedSectionData {
            changeSearchedSection(searchedSection: nil)
        }
        if let searchedText = searchedText {
            performSearch(nil)
        }
    }
    
    var searchedSectionIndex: Int? {
        guard let searchedSectionData = searchedSectionData else { return nil }
        return searchedSections.firstIndex { $0 == searchedSectionData.section }
    }
    
    var searchedSections: [Section] {
        return dataSourceAll.filter {
            if isSearching {
               !($0.isEmpty || !$0.isActive)
            } else {
                $0.isAvailable
            }
        }.map { $0.section }
    }
    
    var isSearchingSection: Bool {
       return searchedSectionData != nil
    }

    var isSearching: Bool {
        return isSearchingText || isSearchingSection
    }
    
    var isSearchingText: Bool {
        return searchedText != "" && searchedText != nil
    }

    func changeSearchedSection(searchedSection index: Int?) {
       
        if let index = index {
            searchedSectionData = getSectionDataForView(index: index)
        } else {
            searchedSectionData = nil
        }
        
        dataSourceAll.forEach { sectionData in
            if sectionData != searchedSectionData && index != nil {
                deactivateSectionData(sectionData)
            }
        }
        
        dataSourceAll.forEach { sectionData in
            if sectionData == searchedSectionData || index == nil {
                activateSectionData(sectionData)
            }
        }
        if let self = self as? INotifyOnChanged {
            self.changed.raise()
        }
    }
    
    private func activateSectionData(_ sectionData: SectionData) {
        let section = sectionData.section
        
        guard let index = getIndexSection(forSection: section) else { return }
        dataSourceAll[index].isSearched = true
        
        guard sectionData.isAvailable,
              getIndexSectionForView(forSection: section) == nil else { return }
        
        if dataSourceForView.isEmpty {
            dataSourceForView.append(sectionData)
        } else {
            guard let availableIndex = getIndexOfActiveSectionForView(sectionData: sectionData) else { return }
            dataSourceForView.insert(sectionData, at: availableIndex)
        }
        
        guard let index = getIndexSectionForView(forSection: sectionData.section) else { return }
        
        Task { [weak self] in
            guard let self = self else { return }
             insertSectionOnView(sectionData.section, index)
        }
        
        sectionData.rows.enumerated { row, rowIndex in
            Task { [weak self] in
                guard let self = self else { return }
                insertItemOnView(rowIndex, IndexPath(row: row, section: index))
            }
        }
    }
    /// Deactivate
    private func deactivateSectionData(_ sectionData: SectionData) {
        let section = sectionData.section
        guard let index = getIndexSection(forSection: section) else { return }
        dataSourceAll[index].isSearched = false
        
        guard let indexSection = getIndexSectionForView(forSection: section) else { return }
        sectionData.rows.indices.reversed().forEach { row in
            Task { [weak self] in
                guard let self = self else { return }
                removeRowOnView(IndexPath(row: row, section: indexSection))
            }
        }
        Task { [weak self] in
            guard let self = self else { return }
             removeSectionOnView(indexSection)
        }
        dataSourceForView.remove(at: indexSection)
    }
    
    private func getSectionDataForView(index: Int) -> SectionData? {
        var searchedIndex = 0
        
        for sectionData in dataSourceAll {
            
            if sectionData.isEmpty || !sectionData.isActive {
                continue
            }
           
            if index == searchedIndex {
                return sectionData
            }
            searchedIndex += 1
        }
        
        return nil
    }
    
    private func getIndexOfActiveSectionForView(sectionData: SectionData) -> Int? {
        var searchedIndex = 0
        
        for sectionDataAll in dataSourceAll {
            
            if !sectionDataAll.isAvailable {
                continue
            }
           
            if sectionData == sectionDataAll {
                return searchedIndex
            }
            searchedIndex += 1
        }
        
        return nil
    }
    
//    private func activateSectionData(_ sectionData: SectionData) {
//        let section = sectionData.section
//        guard let index = getIndexSection(forSection: section) else { return }
//        dataSourceAll[index].isSearched = true
//        
//        guard sectionData.isAvailable,
//              getIndexSectionForView(forSection: section) == nil else { return }
//        
//        let indexForView = getIndexOfActiveSectionForView(sectionData: sectionData)
//        dataSourceForView.insert(sectionData, at: indexForView)
//        insertSectionOnView(sectionData.section, indexForView)
//        
//        sectionData.rows.enumerated {
//            insertItemOnView($1, IndexPath(row: $0, section: indexForView))
//        }
//    }
    
//    private func deactivateSectionData(_ sectionData: SectionData) {
//        let section = sectionData.section
//        
//        guard let index = getIndexSection(forSection: section) else { return }
//        dataSourceAll[index].isSearched = false
//        
//        guard let indexSection = getIndexSectionForView(forSection: section) else { return }
//        sectionData.rows.indices.reversed().forEach {
//            removeRowOnView(IndexPath(row: $0, section: indexSection))
//        }
//        removeSectionOnView(indexSection)
//        dataSourceForView.remove(at: indexSection)
//    }
    

}
