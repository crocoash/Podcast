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
    
    private func getSectionDataForView(index: Int) -> SectionData? {
        var searchedIndex = 0
        for (i,value) in dataSourceAll.enumerated() {
            
            if value.isEmpty || !value.isActive {
                continue
            }
            searchedIndex += 1
            if value == searchedSectionData {
                return value
            }
        }
        
        return nil
    }
    
    func changeSearchedSection(searchedSection index: Int?) {
       
        if let index = index {
            if searchedSectionData == nil {
                searchedSectionData = getSectionDataForView(at: index)
            } else {
                searchedSectionData = getSectionDataForView(index: index) ?? nil
            }
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
    }
    
    private func activateSectionData(_ sectionData: SectionData) {
        let section = sectionData.section
        guard let index = getIndexSection(forSection: section) else { return }
        dataSourceAll[index].isSearched = true
        
        guard sectionData.isAvailable,
              getIndexSectionForView(forSection: section) == nil else { return }
        
        let indexForView = getIndexForSectionForView(sectionData: sectionData)
        dataSourceForView.insert(sectionData, at: indexForView)
        insertSectionOnView(sectionData.section, indexForView)
        
        sectionData.rows.enumerated {
            insertItemOnView($1, IndexPath(row: $0, section: indexForView))
        }
    }
    
    private func deactivateSectionData(_ sectionData: SectionData) {
        let section = sectionData.section
        
        guard let index = getIndexSection(forSection: section) else { return }
        dataSourceAll[index].isSearched = false
        
        guard let indexSection = getIndexSectionForView(forSection: section) else { return }
        sectionData.rows.indices.reversed().forEach {
            removeRowOnView(IndexPath(row: $0, section: indexSection))
        }
        removeSectionOnView(indexSection)
        dataSourceForView.remove(at: indexSection)
    }
    
//    var searchedSectionIndex: Int? {
//        guard let section = searchedSectionData?.section else { return nil }
//        return getIndexSectionForView(forSection: section)
//    }
//    
//    var numbersOfSectionsForSearching: Int {
//        
//    }
}
