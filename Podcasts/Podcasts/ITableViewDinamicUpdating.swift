//
//  ITableViewDinamicUpdating.swift
//  Podcasts
//
//  Created by Anton on 11.11.2023.
//

import UIKit

protocol ITableViewDinamicUpdating where Self: UITableView & IHaveViewModel {}
extension ITableViewDinamicUpdating where ViewModel: IViewModelDinamicUpdating {
    
    func observeViewModel() {
        
        viewModel.removeSection { [weak self] index in
            guard let self = self else { return }
            deleteSections(IndexSet(integer: index), with: .automatic)
        }
        
        viewModel.removeRow { [weak self] indexPath in
            guard let self = self else { return }
            deleteRows(at: [indexPath], with: .automatic)
        }
        
        viewModel.insertRow { [weak self] row, indexPath in
            guard let self = self else { return }
            insertRows(at: [indexPath], with: .automatic)
        }
        
        viewModel.insertSection { [weak self] section, index in
            guard let self = self else { return }
            insertSections(IndexSet(integer: index), with: .automatic)
        }
        
        viewModel.moveSection { [weak self] index, newIndex in
            guard let self = self else { return }

        }
    }
}


protocol ICollectionViewDinamicUpdating where Self: UICollectionView & IHaveViewModel {}
extension ICollectionViewDinamicUpdating where ViewModel: IViewModelDinamicUpdating {
    
    func observeViewModel() {
        
        viewModel.removeSection { [weak self] index in
            guard let self = self else { return }
            deleteSections(IndexSet(integer: index))
        }
        
        viewModel.removeRow { [weak self] indexPath in
            guard let self = self else { return }
            deleteItems(at: [indexPath])
        }
        
        viewModel.insertRow { [weak self] row, indexPath in
            guard let self = self else { return }
            insertItems(at: [indexPath])
        }
        
        viewModel.insertSection { [weak self] section, index in
            guard let self = self else { return }
            insertSections(IndexSet(integer: index))
        }
        
        viewModel.moveSection { [weak self] index, newIndex in
            guard let self = self else { return }

        }
    }
}

