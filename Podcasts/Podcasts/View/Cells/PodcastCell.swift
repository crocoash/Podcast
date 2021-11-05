//
//  PodcastCell.swift
//  Podcasts
//
//  Created by student on 26.10.2021.
//

import UIKit

// FIXME: По-хорошему добавить TableView, чтобы понимать какая ячейка - PodcastTableViewCell
class PodcastCell: UITableViewCell, CustomTableViewCell {

    // FIXME: Дописываем вконце тип класса, чтобы удобне было читать: Label, ImageView, TextField и т.д.
    @IBOutlet private weak var podcastImage: UIImageView!
    @IBOutlet private weak var podcastName: UILabel!
    @IBOutlet private weak var collectionName: UILabel!
    
    var indexPath: IndexPath!
}

extension PodcastCell {

    // FIXME: Индекс пас не должен передаваться в ячейку
    func configureCell(with podcast: Podcast,_ indexPath: IndexPath) {
        self.indexPath = indexPath
        
        backgroundColor = .white
        podcastName.text = podcast.trackName
        podcastImage.load(string: podcast.artworkUrl160!) // FIXME: форс
        collectionName.text = podcast.collectionName
        
        if podcast.isAddToPlaylist { backgroundColor = .yellow }
    }
}
