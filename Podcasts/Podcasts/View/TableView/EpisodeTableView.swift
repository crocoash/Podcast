//
//  TableView.swift
//  Podcasts
//
//  Created by Anton on 28.04.2023.
//

import UIKit
import CoreData

protocol EpisodeTableViewMyDataSource: AnyObject {
    
    func episodeTableViewDidChangeHeightTableView(_ episodeTableView: EpisodeTableView, height: CGFloat, with lastCell: Bool)
//    func episodeTableView(_ episodeTableView: EpisodeTableView, playButtonDidTouchFor indexPath: IndexPath)
//    
//    func episodeTableView(_ episodeTableView: EpisodeTableView, playButtonDidTouchFor indexPath: IndexPath)
//    func episodeTableView(_ episodeTableView: EpisodeTableView, playButtonDidTouchFor indexPath: IndexPath)
//    func episodeTableView(_ episodeTableView: EpisodeTableView, playButtonDidTouchFor indexPath: IndexPath)
//    func episodeTableView(_ episodeTableView: EpisodeTableView, playButtonDidTouchFor indexPath: IndexPath)
//    func episodeTableView(_ episodeTableView: EpisodeTableView, playButtonDidTouchFor indexPath: IndexPath)
//    func episodeTableView(_ episodeTableView: EpisodeTableView, playButtonDidTouchFor indexPath: IndexPath)

}

class EpisodeTableView: UITableView {
   
    lazy private(set) var defaultRowHeight = frame.width / 3.5
    private var sumOfHeightsOfAllHeaders = CGFloat.zero
    private var paddingBetweenSections = CGFloat(20)
    
    weak var myDataSource: EpisodeTableViewMyDataSource?
    
    //MARK: - PublicMethods
    func configureEpisodeTableView<T: EpisodeTableViewMyDataSource & UITableViewDelegate & UITableViewDataSource>(_ vc: T) {
        self.myDataSource = vc
        self.delegate = vc
        self.dataSource = vc
        
        reloadData()
    }
    
    func openCell(_ cell: UITableViewCell) {
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let self = self,
                  let indexPath = indexPath(for: cell) else { return }
            
            beginUpdates()
            endUpdates()
         
            let offset = rectForRow(at: indexPath).height
            let isLastCell = isLastSectionAndRow(indexPath: indexPath)
            let height = rect(forSection: 0).height
            myDataSource?.episodeTableViewDidChangeHeightTableView(self, height: height, with: isLastCell)
        }
    }
    
    func update(with entity: Any) {
        visibleCells.forEach {
            if let podcastCell = $0 as? PodcastCell {
                podcastCell.update(with: entity)
            }
        }
    }
    
    func isLastSectionAndRow(indexPath: IndexPath) -> Bool {
        return numberOfSections - 1 == indexPath.section && numberOfRows(inSection: indexPath.section) - 1 == indexPath.row
    }
    
    ///BigPlayer
    func getYPositionYFor(indexPath: IndexPath) -> CGFloat {
        return rectForRow(at: indexPath).origin.y
    }
    
    //MARK: - inits
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = paddingBetweenSections
        }
    }
}

//MARK: - Private Methods
extension EpisodeTableView {
    
    private var countOfAllCellsInTableView: Int {
        return (0..<numberOfSections).reduce(into: 0) { $0 += numberOfRows(inSection: $1) }
    }
    
    private func setHeightOfEpisodeTableView() -> CGFloat {
        return countOfAllCellsInTableView.cgFloat * defaultRowHeight + sumOfHeightsOfAllHeaders
    }
}
