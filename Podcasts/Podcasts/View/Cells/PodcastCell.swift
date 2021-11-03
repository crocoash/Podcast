//
//  PodcastCell.swift
//  Podcasts
//
//  Created by student on 26.10.2021.
//

import UIKit

class PodcastCell: UITableViewCell {
    
    @IBOutlet private weak var podcastImage: UIImageView!
    @IBOutlet private weak var podcastName: UILabel!
    @IBOutlet private weak var collectionName: UILabel!
    
    var indexPath: IndexPath! = nil
    
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
        guard let podcast = type as? Podcast,let trackName = podcast.trackName, let urlString = podcast.artworkUrl160, let url = URL(string: urlString) else { return }
        self.indexPath = indexPath
        backgroundColor = .white
        podcastName.text = trackName
        podcastImage.load(url: url)
        collectionName.text = podcast.collectionName
        
        if podcast.isAddToPlaylist { backgroundColor = .yellow }
    }
}
