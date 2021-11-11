//
//  DetailViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit

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
    @IBOutlet weak var removeFromPlaylistBookmark: UIImageView!
    @IBOutlet weak var addToPlaylistBookmark: UIImageView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    
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
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func addBookmarkOnTouchUpInside(_ sender: UIButton) {
        delegate?.detailViewController(self, addButtonDidTouchFor: podcast)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func removeBookmarkOnTouchUpInside(_ sender: UIButton) {
        delegate?.detailViewController(self, removeButtonDidTouchFor: podcast)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func backAction(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @objc private func shareButtonOnTouch(_ sender: UITapGestureRecognizer) {
        let text = "You should definitely listen to this!"
        let shareVC = UIActivityViewController(activityItems: [text, podcast.trackViewUrl! ,episodeImage.image! ], applicationActivities: [])
    
        if let popoverController = shareVC.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = self.view.bounds
        }
        self.present(shareVC, animated: true, completion: nil)
    }
}

extension DetailViewController {
    
    private func setupView(){
        removeFromPlaylistBookmark.isHidden = true
        removeFromPlaylistBookmark.isUserInteractionEnabled = false
        DataProvider().downloadImage(string: podcast.artworkUrl600) { [weak self] image in
            self?.episodeImage.image = image
        }
        
        if PlaylistDocument.shared.isPodcastInPlaylist(podcast){
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
        formatDate()
        
        guard let milis = podcast.trackTimeMillis else {
            durationLabel.text = "Unknown"
            return
        }
        
        durationLabel.text = String((milis / 1000) / 60) + " min"
    }
    
    private func formatDate() {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let dateFormatterSet = DateFormatter()
        dateFormatterSet.dateFormat = "MMM d, yyyy"
        
        guard let releaseDate = podcast.releaseDate else {
            fatalError("Invalid date in DetailViewController")
        }
        
        if let date = dateFormatterGet.date(from: releaseDate) {
            dateLabel.text = dateFormatterSet.string(from: date)
        }
    }
    
   
    
    private func configureGestures() {
        backImageView.addMyGestureRecognizer(self, type: .tap(1), selector: #selector(backAction))
        removeFromPlaylistBookmark.addMyGestureRecognizer(self, type: .tap(1), selector: #selector(removeBookmarkOnTouchUpInside))
        addToPlaylistBookmark.addMyGestureRecognizer(self, type: .tap(1), selector: #selector(addBookmarkOnTouchUpInside))
        playImageView.addMyGestureRecognizer(self, type: .tap(1), selector: #selector(playButtonOnTouchUpInside))
        shareImageView.addMyGestureRecognizer(self, type: .tap(1), selector: #selector(shareButtonOnTouch))
    }
}
