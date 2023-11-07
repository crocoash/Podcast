//
//  ITableViewSorting.swift
//  Podcasts
//
//  Created by Anton on 07.11.2023.
//

import Foundation

protocol ITableViewSorting {
    
    associatedtype TypeSortOfTableView
    
    var typeOfSort: TypeSortOfTableView { get set }
}
