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

class EpisodeTableView: UITableView {
   
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
