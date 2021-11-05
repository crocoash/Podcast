//
//  PodcastByAuthorCell.swift
//  Podcasts
//
//  Created by student on 26.10.2021.
//

import UIKit

class PodcastByAuthorCell: UITableViewCell, CustomTableViewCell {
    
    @IBOutlet private weak var label: UILabel! // FIXME: Дать конкретное нвзвание
    
     var indexPath: IndexPath!
}

extension PodcastByAuthorCell {
    
    func configureCell(with author: Author,_ indexPath: IndexPath) {
        self.indexPath = indexPath
        
        label.text = author.artistName ?? "no name"
    }
}
