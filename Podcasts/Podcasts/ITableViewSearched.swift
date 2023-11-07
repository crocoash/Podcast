//
//  ITableViewSearched.swift
//  Podcasts
//
//  Created by Anton on 06.11.2023.
//

import Foundation

//MARK: - Searched
protocol ITableViewSearched where Self: ITableViewModel & INotifyOnChanged {
    var searchedSectionData: SectionData? { get set }
    var searchedText: String? { get set }
    
    func performSearch(_ text: String?)
    func changeSearchedSection(searchedSection index: Int?)
}

extension ITableViewSearched {
    
    func changeSearchedSection(searchedSection index: Int?) {
        searchedSectionData = nil
        guard let index = index, !isEmpty else { return }
        searchedSectionData = getSectionData(at: index)
        changed.raise()
    }
}
