//
//  PodcastCell.swift
//  Podcasts
//
//  Created by student on 26.10.2021.
//

import UIKit

class PodcastCell: UITableViewCell {
    
    private(set) var indexPath: IndexPath! = nil
    
    @IBOutlet private  weak var label: UILabel!
    var topInset: CGFloat = 0
    var leftInset: CGFloat = 0
    var rightInset: CGFloat = 0
    var bottomInset: CGFloat = 0
    
    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        self.layoutMargins = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    }
}

extension PodcastCell: CustomTableViewCell {
   
    func layoutMargins(inset: UIEdgeInsets) {
        topInset = inset.top
        leftInset = inset.left
        rightInset = inset.right
        bottomInset = inset.bottom
    }
    
    func configureCell<T>(with type: T,_ indexPath: IndexPath) {
        guard let podcast = type as? Podcast else { return }
        self.indexPath = indexPath
        backgroundColor = .white
        label.text = "\(podcast.artistIds)" + " " + "\(podcast.isAddToPlaylist)"
        if podcast.isAddToPlaylist { backgroundColor = .yellow }
    }
}
