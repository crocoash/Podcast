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
}

protocol EpisodeTableViewMyDelegate: AnyObject {
    
    func episodeTableView(_ episodeTableView: EpisodeTableView, didSelectStar indexPath: IndexPath)
    func episodeTableView(_ episodeTableView: EpisodeTableView, didSelectDownLoadImage indexPath: IndexPath)
    func episodeTableView(_ episodeTableView: EpisodeTableView, didTouchPlayButton indexPath: IndexPath)
    func episodeTableView(_ episodeTableView: EpisodeTableView, didTouchStopButton indexPath: IndexPath)
}

class EpisodeTableView: UITableView {
   
    lazy private(set) var defaultRowHeight = frame.width / 3.5
    private var sumOfHeightsOfAllHeaders = CGFloat.zero
    private var paddingBetweenSections = CGFloat(20)
    
    weak var myDataSource: EpisodeTableViewMyDataSource?
    weak var myDelegate: EpisodeTableViewMyDelegate?

    
    //MARK: - PublicMethods
    func configureEpisodeTableView<T: EpisodeTableViewMyDataSource & EpisodeTableViewMyDelegate & UITableViewDelegate & UITableViewDataSource>(_ vc: T) {
        self.myDataSource = vc
        self.myDelegate = vc
        self.delegate = vc
        self.dataSource = vc
        
        reloadData()
    }
    
    func openCell(at indexPath: IndexPath) {
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let self = self,
                  let cell = cellForRow(at: indexPath) else { return }
            
            cell.isSelected = !cell.isSelected
            
            beginUpdates()
            endUpdates()
         
            let isLastCell = isLastSectionAndRow(indexPath: indexPath)
            let height = rect(forSection: 0).height
            myDataSource?.episodeTableViewDidChangeHeightTableView(self, height: height, with: isLastCell)
        }
    }
    
    func update(with entity: Any) {
        visibleCells.forEach {
            if let podcastCell = $0 as? PodcastCell {
                podcastCell.update(with: entity)
            } else if let listCell = $0 as? ListeningPodcastCell {
                listCell.update(with: entity)
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

//MARK: - PodcastCellDelegate
extension EpisodeTableView: PodcastCellDelegate {
    
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell) {
        guard let indexPath = indexPath(for: podcastCell) else { return }
        myDelegate?.episodeTableView(self, didSelectStar: indexPath)
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell) {
        guard let indexPath = indexPath(for: podcastCell) else { return }
        myDelegate?.episodeTableView(self, didSelectDownLoadImage: indexPath)
    }
    
    func podcastCellDidTouchPlayButton(_ podcastCell: PodcastCell) {
        guard let indexPath = indexPath(for: podcastCell) else { return }
        myDelegate?.episodeTableView(self, didTouchPlayButton: indexPath)
    }
    
    func podcastCellDidTouchStopButton(_ podcastCell: PodcastCell) {
        guard let indexPath = indexPath(for: podcastCell) else { return }
        myDelegate?.episodeTableView(self, didTouchStopButton: indexPath)
    }
}
