//
//  PodcastByAuthorCell.swift
//  Podcasts
//
//  Created by student on 26.10.2021.
//

import UIKit

class PodcastByAuthorCell: UITableViewCell {
    
    @IBOutlet private weak var label: UILabel!
}

extension PodcastByAuthorCell {
    
    func configureCell(with author: Author) {
        
        label.text = author.artistName ?? "no name"
    }
}
