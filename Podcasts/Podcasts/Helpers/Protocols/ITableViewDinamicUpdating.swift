//
//  ITableViewDinamicUpdating.swift
//  Podcasts
//
//  Created by Anton on 11.11.2023.
//

import UIKit

protocol ITableViewDinamicUpdating: UITableView & IHaveViewModel where ViewModel: IViewModelDinamicUpdating  {}
extension ITableViewDinamicUpdating {
    
     func observeViewModel() {
        
        viewModel.removeSection { index in
            Task { @MainActor [weak self]  in
                guard let self = self else { return }
                deleteSections(IndexSet(integer: index), with: .automatic)
            }
        }
        
        viewModel.removeRow {  indexPath in
            Task { @MainActor [weak self]  in
                guard let self = self else { return }
                deleteRows(at: [indexPath], with: .automatic)
            }
        }
        viewModel.insertRow { [weak self] row, indexPath in
            Task { @MainActor [weak self]  in
                guard let self = self else { return }
                insertRows(at: [indexPath], with: .automatic)
            }
        }
        
        viewModel.insertSection { [weak self] section, index in
            Task { @MainActor [weak self]  in
                guard let self = self else { return }
                insertSections(IndexSet(integer: index), with: .automatic)
                
            }
        }
        
        viewModel.moveSection { [weak self] index, newIndex in
            //TODO: -
            guard let _ = self else { return }
        }
    }
}


protocol ICollectionViewDinamicUpdating where Self: UICollectionView & IHaveViewModel {}
extension ICollectionViewDinamicUpdating where ViewModel: IViewModelDinamicUpdating {
    
    @MainActor
    func observeViewModel() {
        
        viewModel.removeSection { [weak self] index in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.deleteSections(IndexSet(integer: index))
            }
        }
        
        viewModel.removeRow { [weak self]  indexPath in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.deleteItems(at: [indexPath])
            }
        }
        
        viewModel.insertRow { [weak self] row, indexPath in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.insertItems(at: [indexPath])
            }
        }
        
        viewModel.insertSection { [weak self] section, index in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.insertSections(IndexSet(integer: index))
            }
        }
        
        viewModel.moveSection { index, newIndex in }
    }
    
}