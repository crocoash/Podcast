//
//  ISearchedSectionData.swift
//  Podcasts
//
//  Created by Anton on 09.11.2023.
//

import Foundation


protocol ISearchedSectionData: ISectionData {
    var isSearched: Bool? { get set }

}

extension ISearchedSectionData {
    var isAvailable: Bool {
        var isSearched1 = true
        if let isSearched = isSearched {
            isSearched1 = isSearched
        }
        return !isEmpty && isActive && isSearched1
    }
}
