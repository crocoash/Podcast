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
    
    func cancelSearching() async {
        if searchedSectionData != nil {
            await changeSearchedSection(searchedSection: nil)
        }
        if searchedText != nil {
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

    func changeSearchedSection(searchedSection index: Int?) async {
       
        if let index = index {
            searchedSectionData = getSectionDataForView(at: index)
        } else {
            searchedSectionData = nil
        }
        
        for sectionData in  dataSourceAll {
            if sectionData != searchedSectionData && index != nil {
               await deactivateSectionData(sectionData)
            }
        }
        
        for sectionData in dataSourceAll {
            if sectionData == searchedSectionData || index == nil {
               await activateSectionData(sectionData)
            }
        }
        if let self = self as? INotifyOnChanged {
            self.changed.raise()
        }
    }
    
    private func activateSectionData(_ sectionData: SectionData) async {
        let section = sectionData.section
        
        guard let index = await getIndexSection(forSection: section) else { return }
        
        dataSourceAll[index].isSearched = true
        guard sectionData.isAvailable,
              getIndexSectionForView(forSection: section) == nil else { return }
        
        if dataSourceForView.isEmpty {
            dataSourceForView.append(sectionData)
        } else {
            guard let availableIndex = await getIndexOfActiveSectionForView1(sectionData: sectionData) else { return }
            dataSourceForView.insert(sectionData, at: availableIndex)
        }
        
        guard let index = getIndexSectionForView(forSection: sectionData.section) else { return }
        
        await insertSectionOnView(sectionData.section, index)
        await sectionData.rows.enumerated { row, rowIndex in
            await insertItemOnView(rowIndex, IndexPath(row: row, section: index))
        }
    }
    /// Deactivate
    private func deactivateSectionData(_ sectionData: SectionData) async {
        let section = sectionData.section
        guard let index = await getIndexSection(forSection: section) else { return }
        dataSourceAll[index].isSearched = false

        guard let indexSection = getIndexSectionForView(forSection: section) else { return }
        
        await sectionData.rows.indices.reversed().forEach { row in
            await removeRowOnView(IndexPath(row: row, section: indexSection))
        }
        await removeSectionOnView(indexSection)
        
        dataSourceForView.remove(at: indexSection)
    }
    
    private func getSectionDataForView(index: Int) async -> SectionData?  {
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
    
    private func getIndexOfActiveSectionForView1(sectionData: SectionData) async -> Int? {
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


}
