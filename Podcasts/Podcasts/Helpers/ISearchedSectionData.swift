//
//  ISearchedSectionData.swift
//  Podcasts
//
//  Created by Anton on 09.11.2023.
//

import Foundation


protocol ISearchedSectionData: ISectionData {
    var isSearched: Bool { get set }
    var isAvailable: Bool { get }
}
