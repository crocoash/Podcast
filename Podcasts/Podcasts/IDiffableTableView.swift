//
//  File.swift
//  Podcasts
//
//  Created by Anton on 24.09.2023.
//

import Foundation
import UIKit

protocol IDiffableTableView: AnyObject {
    
    associatedtype Row: Hashable
    associatedtype Section: Hashable
    
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section,Row>
    typealias DiffableDataSource = UITableViewDiffableDataSource<Section, Row>
    
    var mySnapShot: SnapShot!  { get set }
    var diffableDataSource: DiffableDataSource! { get set }
    
    var countOfSections: Int { get }
    
    func countOfRowsInSection(index: Int) -> Int

    func cellForRowAt(indexPath: IndexPath) -> Row
    func sectionFor(index: Int) -> Section

//    func moveSection(from oldIndex: Int, to newIndex: Int)
    func deleteSection(at index: Int)
    func deleteRow(at indexPath: IndexPath)
    func insertRow(at indexPath: IndexPath)
    func reloadTableView()
    func insertSection(section: Section, at index: Int)
    func reloadSection(indexSection index: Int)
}



extension IDiffableTableView {
    
    func insertSection(section: Section, at index: Int) {
        
        let isLastSection = mySnapShot.numberOfSections < index + 1
        if isLastSection {
            mySnapShot.appendSections([section])
        } else {
            let beforeSection = mySnapShot.sectionIdentifiers[index]
            mySnapShot.insertSections([section], beforeSection: beforeSection)
        }
        diffableDataSource.apply(mySnapShot)
    }
    
    func reloadTableView() {
    
        mySnapShot = SnapShot()
        
        guard countOfSections != 0 else { return }
        for indexSection in 0..<countOfSections {
            reloadSection(indexSection: indexSection)
        }
    }
    
    func insertRow(at indexPath: IndexPath) {

        let cell = cellForRowAt(indexPath: indexPath)
        let section = mySnapShot.sectionIdentifiers[indexPath.section]
        let count = mySnapShot.itemIdentifiers(inSection: section).count

        if count < indexPath.row + 1 {
            mySnapShot.appendItems([cell], toSection: section)
        } else {
            guard let beforeItem = diffableDataSource.itemIdentifier(for: indexPath) else { return }
            mySnapShot.insertItems([cell], beforeItem: beforeItem)
        }
        diffableDataSource.apply(mySnapShot)
    }
    
    func reloadSection(indexSection index: Int) {
        
        let countOfItems = countOfRowsInSection(index: index)
        
        var cells = [Row]()
        
        for indexRow in 0..<countOfItems {
            let indexPath = IndexPath(item: indexRow, section: index)
            let cell: Row = cellForRowAt(indexPath: indexPath)
            cells.append(cell)
        }
        
        let section = sectionFor(index: index)
        mySnapShot.appendSections([section])
        mySnapShot.appendItems(cells)
        diffableDataSource.apply(mySnapShot)
    }
    
    func deleteSection(at index: Int) {
        let section = mySnapShot.sectionIdentifiers[index]
        mySnapShot.deleteSections([section])
        diffableDataSource.apply(mySnapShot)
    }
    
    func deleteRow(at indexPath: IndexPath) {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else { return }
        mySnapShot.deleteItems([item])
        diffableDataSource.apply(mySnapShot)
    }
}


protocol IDiffableTableViewWithDataSource: IDiffableTableView {
}

extension IDiffableTableViewWithDataSource {
}


protocol IDiffableTableViewWithModel: IHaveViewModel, IDiffableTableView where ViewModel: ITableViewModel, Row == ViewModel.Row, Section == ViewModel.Section {
    
    func observeViewModel()
}

extension IDiffableTableViewWithModel {
    
    func observeViewModel() {
        if let viewModel = viewModel as? any IViewModelDinamicUpdating {
            viewModel.removeSection { [weak self] index in
                guard let self = self else { return }
                deleteSection(at: index)
            }
            
            viewModel.removeRow { [weak self] indexPath in
                guard let self = self else { return }
                deleteRow(at: indexPath)
            }
            
            viewModel.insertRow { [weak self] item, indexPath in
                guard let self = self else { return }
                insertRow(at: indexPath)
            }
            
            viewModel.insertSection { [weak self] section, index in
                guard let self = self else { return }
                insertSection(section: section as! Section, at: index)
            }
            
            viewModel.moveSection { [weak self] index, newIndex in
                guard let self = self else { return }
                moveSection(from: index, to: newIndex)
            }
            
            
            //            viewModel.reloadSection { [weak self ] index in
            //                guard let self = self else { return }
            //                reloadSection(indexSection: index)
            //            }
        }
    }
    
    func cellForRowAt(indexPath: IndexPath) -> Row {
        return viewModel.getRowForView(forIndexPath: indexPath)
    }
    
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
        diffableDataSource.apply(mySnapShot)
    }
        
    func sectionFor(index: Int) -> Section {
        return viewModel.getSectionForView(sectionIndex: index)
    }
    
    var countOfSections: Int {
        return viewModel.numbersOfSections
    }
    
    func countOfRowsInSection(index: Int) -> Int {
        return viewModel.numbersOfRowsInSection(section: index)
    }
}


