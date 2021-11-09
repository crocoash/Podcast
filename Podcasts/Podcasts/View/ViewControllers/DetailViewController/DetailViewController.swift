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
    
    private var index : Int!
    private var podcast : Podcast!
    
    weak var delegate: DetailViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureGestures()
        setupView()
        self.view.addMyGestureRecognizer(self, type: .tap(), selector: #selector(dismissOnScreenTap))
        
        var frame = self.view.frame
        frame.size.height = self.view.frame.height - 200
        self.view.frame = frame
    }
    
    func setUp(index: Int, podcast: Podcast) {
        self.index = index
        self.podcast = podcast
    }
    
    @IBAction private func listenButtonOnTouchUpInside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        delegate?.detailViewController(self, playButtonDidTouchFor: index)
    }
    
    @objc private func dismissOnScreenTap(_ sender: UIGestureRecognizer) {
        dismiss(animated: true)
    }
}

extension DetailViewController {
    
    private func setupView(){
        DataProvider().downloadImage(string: podcast.artworkUrl600) { [weak self] image in
            self?.episodeImage.image = image
        }
        
        episodeName.text = podcast.trackName
        collectionName.text = podcast.trackName
        descriptionTextView.text = podcast.description
    }
    
    private func configureGestures() {
        view.addMyGestureRecognizer(self, type: .screenEdgePanGestureRecognizer(directions: [.right]), selector: #selector(dismissOnScreenTap))
        view.addMyGestureRecognizer(self, type: .tap(), selector: #selector(dismissOnScreenTap))
    }
}
