//
//  TableView.swift
//  Podcasts
//
//  Created by Anton on 28.04.2023.
//

import UIKit
import CoreData

@objc protocol EpisodeTableViewMyDataSource: AnyObject {
    func episodeTableViewDidChangeHeightTableView(_ episodeTableView: EpisodeTableView, height: CGFloat, withLastCell isLastCell: Bool)
}

class EpisodeTableView: UITableView, IHaveViewModel {
    
    func viewModelChanged() {
        
    }
    
//    func changeViewModel(with viewModelArguments: ViewModel.Arguments) {
//        observeViewModel()
//    }
    
    func viewModelChanged(_ viewModel: EpisodeTableViewModel) {
        observeViewModel()
    }
    
    typealias ViewModel = EpisodeTableViewModel
   
    lazy private(set) var defaultRowHeight = CGFloat(100)//frame.width / 3.5
    lazy private(set) var defaultSectionHeight = CGFloat(40)
    
    private var paddingBetweenSections = CGFloat(0)
    
    @IBOutlet weak var myDataSource: EpisodeTableViewMyDataSource?
    
    //MARK: - PublicMethods
    func openCell(at indexPath: IndexPath) {
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let self = self,
                  let cell = cellForRow(at: indexPath) else { return }
            
            cell.isSelected = !cell.isSelected
            
            beginUpdates()
            endUpdates()
         
            let isLastCell = isLastSectionAndRow(indexPath: indexPath)
            myDataSource?.episodeTableViewDidChangeHeightTableView(self, height: height, withLastCell: isLastCell)
        }
    }
    
    func isLastSectionAndRow(indexPath: IndexPath) -> Bool {
        return numberOfSections - 1 == indexPath.section && numberOfRows(inSection: indexPath.section) - 1 == indexPath.row
    }
    
    func changeTypeOfSort(_ sort: ViewModel.TypeSortOfTableView) {
        viewModel.typeOfSort = sort
        
    }
    
    var height: CGFloat {
        return (0..<numberOfSections ).reduce(into: 0) { $0 += (rect(forSection: $1).height + paddingBetweenSections) }
    }
    
    ///BigPlayer
    func getYPositionYFor(indexPath: IndexPath) -> CGFloat {
        return rectForRow(at: indexPath).origin.y
    }

    //MARK: init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = paddingBetweenSections
        }

        delegate = self
        dataSource = self
    }
    
    //MARK: Public Methods
    @objc func tapCell(sender: UITapGestureRecognizer) {
       guard let cell = sender.view as? PodcastCell,
             cell.moreThanThreeLines,
             let indexPath = indexPath(for: cell)
       else { return }
       
       openCell(at: indexPath)
    }
}

//MARK: - Private Methods
extension EpisodeTableView {
    
    private func observeViewModel() {
        viewModel.removeSection { [weak self] index in
            guard let self = self else { return }
            deleteSections(IndexSet(integer: index), with: .automatic)
//            myDataSource?.episodeTableViewDidChangeHeightTableView(self, height: height, withLastCell: <#T##Bool#>)
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

//MARK: - UITableViewDelegate
extension EpisodeTableView: UITableViewDelegate {
   
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
      if let cell = tableView.cellForRow(at: indexPath), cell.isSelected {
         if let cell = cell as? PodcastCell, cell.moreThanThreeLines {
            return UITableView.automaticDimension
         }
      }
      return defaultRowHeight
   }
   
   func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return defaultSectionHeight
   }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return defaultRowHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return defaultSectionHeight
    }
}

//MARK: - UITableViewDataSource
extension EpisodeTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numbersOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numbersOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.getInputSection(sectionIndex: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
        let podcast = viewModel.getRow(forIndexPath: indexPath)
        cell.addMyGestureRecognizer(self, type: .tap(), #selector(tapCell))
        
        let podcasts = viewModel.getRows(atSection: indexPath.section)
        let args = PodcastCellViewModel.Arguments.init(podcast: podcast, playlist: podcasts)
        cell.viewModel = viewModel.container.resolve(args: args)
        return cell
    }
}
