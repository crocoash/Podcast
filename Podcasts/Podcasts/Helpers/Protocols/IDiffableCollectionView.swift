//
//  IDiffableCollectionView.swift
//  Podcasts
//
//  Created by Anton on 12.11.2023.
//

import Foundation
import UIKit

protocol IDiffableCollectionView: AnyObject {
    
    associatedtype Row: Hashable
    associatedtype Section: Hashable
    
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section,Row>
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, Row>
    
    @MainActor var snapShot: SnapShot!  { get set }
    @MainActor var diffableDataSource: DiffableDataSource! { get set }
    
    var countOfSections: Int { get }
    
    func countOfRowsInSection(index: Int) -> Int

    func cellForRowAt(indexPath: IndexPath) -> Row
    func sectionFor(index: Int) -> Section


    func deleteSection(at index: Int)
    func deleteRow(at indexPath: IndexPath)
    func insertRow(at indexPath: IndexPath)
    func reloadTableView()
    func insertSection(section: Section, at index: Int)
    func reloadSection(indexSection index: Int)
}


extension IDiffableCollectionView {
    
    func insertSection(section: Section, at index: Int) {
        Task { @MainActor in
            
            let isLastSection = snapShot.numberOfSections < index + 1
            if isLastSection {
                snapShot.appendSections([section])
            } else {
                let beforeSection = snapShot.sectionIdentifiers[index]
                snapShot.insertSections([section], beforeSection: beforeSection)
            }
            diffableDataSource.apply(snapShot)
        }
    }
    
    func reloadTableView() {
        Task { @MainActor in
            snapShot = SnapShot()
            guard countOfSections != 0 else { return }
            for indexSection in 0..<countOfSections {
                reloadSection(indexSection: indexSection)
            }
        }
    }
    
    func insertRow(at indexPath: IndexPath) {
        Task { @MainActor in
            let cell = cellForRowAt(indexPath: indexPath)
            let section = snapShot.sectionIdentifiers[indexPath.section]
            let count = snapShot.itemIdentifiers(inSection: section).count
            
            if count < indexPath.row + 1 {
                snapShot.appendItems([cell], toSection: section)
            } else {
                guard let beforeItem = diffableDataSource.itemIdentifier(for: indexPath) else { return }
                snapShot.insertItems([cell], beforeItem: beforeItem)
            }
            diffableDataSource.apply(snapShot)
        }
    }
    
    func reloadSection(indexSection index: Int) {
        Task { @MainActor in
            let countOfItems = countOfRowsInSection(index: index)
            
            var cells = [Row]()
            
            for indexRow in 0..<countOfItems {
                let indexPath = IndexPath(item: indexRow, section: index)
                let cell: Row = cellForRowAt(indexPath: indexPath)
                cells.append(cell)
            }
            
            let section = sectionFor(index: index)
            
            snapShot.appendSections([section])
            snapShot.appendItems(cells)
            diffableDataSource.apply(snapShot)
        }
    }
    
    func deleteSection(at index: Int) {
        Task { @MainActor in
            let section = snapShot.sectionIdentifiers[index]
            snapShot.deleteSections([section])
            diffableDataSource.apply(snapShot)
        }
    }
    
    func deleteRow(at indexPath: IndexPath) {
        Task { @MainActor in
            guard let item = diffableDataSource.itemIdentifier(for: indexPath) else { return }
            snapShot.deleteItems([item])
            diffableDataSource.apply(snapShot)
        }
    }
    
    func moveSection(from oldIndex: Int, to newIndex: Int) {
        Task { @MainActor in

            let countOfSections = snapShot.sectionIdentifiers.count - 1
            let isFirstSection = newIndex == 0
            let isLastSection = newIndex == countOfSections
            
            let section = snapShot.sectionIdentifiers[oldIndex]
            
            if isFirstSection {
                let firstSection = snapShot.sectionIdentifiers[0]
                snapShot.moveSection(section, beforeSection: firstSection)
            } else if isLastSection {
                let lastSection = snapShot.sectionIdentifiers[countOfSections]
                snapShot.moveSection(section, afterSection: lastSection)
            } else {
                let beforeSection = snapShot.sectionIdentifiers[newIndex]
                snapShot.moveSection(section, beforeSection: beforeSection)
            }
            diffableDataSource.apply(snapShot)
        }
    }
}


protocol IDiffableCollectionViewWithDataSource: IDiffableCollectionView {
    
}

extension IDiffableCollectionViewWithDataSource {
    
}


protocol IDiffableCollectionViewWithModel: IHaveViewModel, IDiffableCollectionView where ViewModel: ITableViewModel, Row == ViewModel.Row, Section == ViewModel.Section {
    func observeViewModel() 
}

 extension IDiffableCollectionViewWithModel {
    
    func observeViewModel() async {
        if let viewModel = viewModel as? any IViewModelDinamicUpdating {
            
            viewModel.removeSection { [weak self]  index in
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
        }
        
        
            //            viewModel.reloadSection { [weak self ] index in
            //                guard let self = self else { return }
            //                reloadSection(indexSection: index)
            //            }
    }
    
    func cellForRowAt(indexPath: IndexPath) -> Row {
        return viewModel.getRowForView(forIndexPath: indexPath)
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
