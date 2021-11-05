//
//  DetailViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit

protocol DetailViewControllerDelegate: AnyObject {
    func detailViewController(_ detailViewController: DetailViewController, playButtonDidTouchFor podcastIndex: Int)
}

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
        // FIXME: В приватный метод, селф лишний
        self.view.addMyGestureRecognizer(self, type: .tap(), selector: #selector(dismissOnScreenTap))
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
        episodeImage.load(string: podcast.artworkUrl600)
        episodeName.text = podcast.trackName
        collectionName.text = podcast.trackName
        descriptionTextView.text = podcast.description
    }
    
    private func configureGestures() {
        view.addMyGestureRecognizer(self, type: .screenEdgePanGestureRecognizer(directions: [.right]), selector: #selector(dismissOnScreenTap))
    }
}
