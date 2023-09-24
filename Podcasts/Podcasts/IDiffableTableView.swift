//
//  File.swift
//  Podcasts
//
//  Created by Anton on 24.09.2023.
//

import Foundation
import UIKit

protocol IDiffableTableView: AnyObject where Self: UITableView {
    associatedtype Row: Hashable
    associatedtype Section: Hashable
    associatedtype DiffableDataSource: UITableViewDiffableDataSource<Section, Row>
    
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section,Row>
    
    var mySnapShot:         SnapShot!   { get set }
    var diffableDataSource: DiffableDataSource! { get set }
    
    func cellForRowAt(indexPath: IndexPath) -> Row
    func sectionFor(index: Int) -> Section
    func countOfSections() -> Int
    func countOfRowsInSection(index: Int) -> Int
}

extension IDiffableTableView {
    
    func moveSection(from oldIndex: Int, to newIndex: Int) {
        
        let countOfSections = mySnapShot.sectionIdentifiers.count - 1
        let isFirstSection = newIndex == 0
        let isLastSection = newIndex == countOfSections
        
        let section = mySnapShot.sectionIdentifiers[oldIndex]
        
        if isFirstSection {
            let firstSection = mySnapShot.sectionIdentifiers[0]
            mySnapShot.moveSection(section, beforeSection: firstSection)
        } else if isLastSection {
            let lastSection = mySnapShot.sectionIdentifiers[countOfSections]
            mySnapShot.moveSection(section, afterSection: lastSection)
        } else {
            let beforeSection = mySnapShot.sectionIdentifiers[newIndex]
            mySnapShot.moveSection(section, beforeSection: beforeSection)
        }
        reloadData()
    }
    
    func deleteSection(at index: Int) {
        let section = mySnapShot.sectionIdentifiers[index]
        mySnapShot.deleteSections([section])
        reloadData()
    }
    
    func deleteItem(at indexPath: IndexPath) {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else { return }
        mySnapShot.deleteItems([item])
        reloadData()
    }
    
    func insertCell(at indexPath: IndexPath) {

        let cell = cellForRowAt(indexPath: indexPath)
        let section = mySnapShot.sectionIdentifiers[indexPath.section]
        let count = mySnapShot.itemIdentifiers(inSection: section).count

        if count < indexPath.row + 1 {
            mySnapShot.appendItems([cell], toSection: section)
        } else {
            guard let beforeItem = diffableDataSource.itemIdentifier(for: indexPath) else { fatalError() }
            mySnapShot.insertItems([cell], beforeItem: beforeItem)
        }
        
        reloadData()
    }
    
    func insertSection(at index: Int) {
        let section = sectionFor(index: index)
        
        let isLastSection = mySnapShot.numberOfSections < index + 1
        
        if isLastSection {
            mySnapShot.appendSections([section])
        } else {
            let beforeSection = mySnapShot.sectionIdentifiers[index]
            mySnapShot.insertSections([section], beforeSection: beforeSection)
        }
        reloadData()
    }
    
    func reloadTableView() {
        
        let countOfSections = countOfSections()
        self.mySnapShot = SnapShot()
        
        guard countOfSections != 0 else { return }
        
        for indexSection in 0..<countOfSections {
            
            let countOfItems = countOfRowsInSection(index: indexSection)
            
            var cells = [Row]()
            
            for indexRow in 0..<countOfItems {
                let indexPath = IndexPath(item: indexRow, section: indexSection)
                let cell: Row = cellForRowAt(indexPath: indexPath)
                cells.append(cell)
            }
            
            let section = sectionFor(index: indexSection)
            mySnapShot.appendSections([section])
            mySnapShot.appendItems(cells)
        }
        
        diffableDataSource.apply(mySnapShot)
    }
}
