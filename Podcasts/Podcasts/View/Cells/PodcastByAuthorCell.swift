//
//  PodcastByAuthorCell.swift
//  Podcasts
//
//  Created by student on 26.10.2021.
//

import UIKit

class PodcastByAuthorCell: UITableViewCell {
    var topInset: CGFloat = 0
    var leftInset: CGFloat = 0
    var rightInset: CGFloat = 0
    var bottomInset: CGFloat = 0
    
    @IBOutlet weak var label: UILabel!
    
    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        self.layoutMargins = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    }
}

extension PodcastByAuthorCell: CustomTableViewCell {
    
    func layoutMargins(inset: UIEdgeInsets) {
        topInset = inset.top
        leftInset = inset.left
        rightInset = inset.right
        bottomInset = inset.bottom
    }
    
    func configureCell<T>(with type: T,_ indexPath: IndexPath) {
        guard let author = type as? Author else { return }
        label.text = author.artistName ?? "ddcsc"
    }
}
