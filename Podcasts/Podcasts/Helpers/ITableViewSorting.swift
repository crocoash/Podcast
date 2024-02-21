//
//  ITableViewSorting.swift
//  Podcasts
//
//  Created by Anton on 07.11.2023.
//

import Foundation

protocol ITableViewSorting where Self: ITableViewModel {
    
    associatedtype TypeSortOfTableView
    
    var typeOfSort: TypeSortOfTableView { get set }
}

extension ITableViewSorting {
    
    func changeTypeOfSort(_ typeOfSort: TypeSortOfTableView) {
        self.typeOfSort = typeOfSort
    }
}
