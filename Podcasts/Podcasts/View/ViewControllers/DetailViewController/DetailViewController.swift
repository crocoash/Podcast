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
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    private var index : Int!
    private var podcast : Podcast!
    
    weak var delegate: DetailViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setUp(index: Int, podcast: Podcast) {
        self.index = index
        self.podcast = podcast
    }
    
    @IBAction private func listenButtonOnTouchUpInside(_ sender: UIButton) {
        delegate?.detailViewController(self, playButtonDidTouchFor: index)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func addButtonOnTouchUpInside(_ sender: UIButton) {
        delegate?.detailViewController(self, addButtonDidTouchFor: podcast)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func removeButtonOnTouchUpInside(_ sender: UIButton) {
        delegate?.detailViewController(self, removeButtonDidTouchFor: podcast)
        self.navigationController?.popViewController(animated: true)
    }
}

extension DetailViewController {
    
    private func setupView(){
        removeButton.isHidden = true
        removeButton.isEnabled = false
        DataProvider().downloadImage(string: podcast.artworkUrl600) { [weak self] image in
            self?.episodeImage.image = image
        }
        if PlaylistDocument.shared.isPodcastInPlaylist(podcast){
            addButton.isHidden = true
            addButton.isEnabled = false
            removeButton.isHidden = false
            removeButton.isEnabled = true
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
}
