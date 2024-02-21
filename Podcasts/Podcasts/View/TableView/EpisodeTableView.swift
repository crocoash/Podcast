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

class EpisodeTableView: UITableView, IHaveViewModel, ITableViewDinamicUpdating {
    
    func viewModelChanged(_ viewModel: EpisodeTableViewModel) {
        configureUI()
    }
    
    func viewModelChanged() {
        myDataSource?.episodeTableViewDidChangeHeightTableView(self, height: height, withLastCell: false)
    }
    
    typealias ViewModel = EpisodeTableViewModel
   
    lazy private(set) var defaultRowHeight = CGFloat(100.6)//frame.width / 3.5
    lazy private(set) var defaultSectionHeight = CGFloat(40)
    
    private var paddingBetweenSections = CGFloat(0)
    
    @IBOutlet weak var myDataSource: EpisodeTableViewMyDataSource?
    
    func isLastSectionAndRow(indexPath: IndexPath) -> Bool {
        return numberOfSections - 1 == indexPath.section && numberOfRows(inSection: indexPath.section) - 1 == indexPath.row
    }
    
    var height: CGFloat {
        return (0..<numberOfSections ).reduce(into: 0) { $0 += (rect(forSection: $1).height + paddingBetweenSections) }
    }
    
    func selectRowAt(indexPath: IndexPath) {
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let self = self,
                  let cell = cellForRow(at: indexPath) else { return }
            
            cell.isSelected = !cell.isSelected
        }
        beginUpdates()
        endUpdates()
    
        let isLastCell = isLastSectionAndRow(indexPath: indexPath)
        myDataSource?.episodeTableViewDidChangeHeightTableView(self, height: height, withLastCell: isLastCell)
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
    }
    
    func configureUI() {
        observeViewModel()
        delegate = self
        dataSource = self
    }
    
    func updateUI() {}
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
        return viewModel.getSectionForView(sectionIndex: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.getCell(tableView, for: indexPath)
    }
}
