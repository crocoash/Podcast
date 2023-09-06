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

@objc protocol EpisodeTableViewMyDelegate: AnyObject {
    
    func episodeTableView(_ episodeTableView: EpisodeTableView, didSelectStar indexPath: IndexPath)
    func episodeTableView(_ episodeTableView: EpisodeTableView, didSelectDownLoadImage indexPath: IndexPath)
    func episodeTableView(_ episodeTableView: EpisodeTableView, didTouchPlayButton indexPath: IndexPath)
    func episodeTableView(_ episodeTableView: EpisodeTableView, didTouchStopButton indexPath: IndexPath)
}

class EpisodeTableView: UITableView {
   
    lazy private(set) var defaultRowHeight = CGFloat(100)//frame.width / 3.5
    lazy private(set) var defaultSectionHeight = CGFloat(40)
    
    private var paddingBetweenSections = CGFloat(0)
    
    @IBOutlet weak var myDataSource: EpisodeTableViewMyDataSource?
    @IBOutlet weak var myDelegate: EpisodeTableViewMyDelegate?
    
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
    
    var height: CGFloat {
        return (0..<numberOfSections ).reduce(into: 0) { $0 += (rect(forSection: $1).height + paddingBetweenSections) }
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
        
        delegate = self
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
