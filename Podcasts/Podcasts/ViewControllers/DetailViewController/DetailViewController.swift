//
//  DetailViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit

protocol DetailViewControllerDelegate: AnyObject {
    
    func detailViewController(_ detailViewController: DetailViewController, playButtonDidTouchFor selectedPodcastAtIndex: Int)
    func detailViewController(_ detailViewController: DetailViewController, addToFavoriteButtonDidTouchFor selectedPodcast: Podcast)
    func detailViewController(_ detailViewController: DetailViewController, removeFromFavoriteButtonDidTouchFor selectedPodcast: Podcast)
}

class DetailViewController: UIViewController {
    
    @IBOutlet private weak var episodeImage: UIImageView!
    @IBOutlet private weak var episodeName: UILabel!
    @IBOutlet private weak var collectionName: UILabel!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var advisoryRatingLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var backImageView: UIImageView!
    @IBOutlet private weak var removeFromPlaylistBookmark: UIImageView!
    @IBOutlet private weak var addToPlaylistBookmark: UIImageView!
    @IBOutlet private weak var playImageView: UIImageView!
    
    private var index : Int!
    private var podcast : Podcast!
    
    weak var delegate: DetailViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureGestures()
    }
    
    func setUp(index: Int, podcast: Podcast) {
        self.index = index
        self.podcast = podcast
    }
    
    @objc private func playButtonOnTouchUpInside(_ sender: UIButton) {
        delegate?.detailViewController(self, playButtonDidTouchFor: index)
        dismiss(animated: true)
    }
    
    @objc private func addBookmarkOnTouchUpInside(_ sender: UIButton) {
        delegate?.detailViewController(self, addToFavoriteButtonDidTouchFor: podcast)
        dismiss(animated: true)
    }
    
    @objc private func removeBookmarkOnTouchUpInside(_ sender: UIButton) {
        delegate?.detailViewController(self, removeFromFavoriteButtonDidTouchFor: podcast)
        dismiss(animated: true)
    }
    
    @objc private func backAction(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension DetailViewController {
    
    private func setupView(){
        removeFromPlaylistBookmark.isHidden = true
        removeFromPlaylistBookmark.isUserInteractionEnabled = false
        DataProvider().downloadImage(string: podcast.artworkUrl600) { [weak self] image in
            self?.episodeImage.image = image
        }
        
        if FavoriteDocument.shared.isFavorite(podcast) {
            addToPlaylistBookmark.isHidden = true
            addToPlaylistBookmark.isUserInteractionEnabled = false
            removeFromPlaylistBookmark.isHidden = false
            removeFromPlaylistBookmark.isUserInteractionEnabled = true
        }

        episodeName.text = podcast.trackName
        collectionName.text = podcast.collectionName
        descriptionTextView.text = podcast.description
        countryLabel.text = podcast.country
        advisoryRatingLabel.text = podcast.contentAdvisoryRating
        dateLabel.text = podcast.releaseDate
        
        if let milis = podcast.trackTimeMillis {
            durationLabel.text = String((milis.intValue / 1000) / 60) + " min"
        } else {
            durationLabel.text = "Unknown"
        }
    }
    
    private func configureGestures() {
        backImageView.addMyGestureRecognizer(self, type: .tap(), #selector(backAction))
        removeFromPlaylistBookmark.addMyGestureRecognizer(self, type: .tap(), #selector(removeBookmarkOnTouchUpInside))
        addToPlaylistBookmark.addMyGestureRecognizer(self, type: .tap(), #selector(addBookmarkOnTouchUpInside))
        playImageView.addMyGestureRecognizer(self, type: .tap(), #selector(playButtonOnTouchUpInside))
        addMyGestureRecognizer(self, type: .screenEdgePanGestureRecognizer(directions: [.left]), #selector(backAction))
    }
}
