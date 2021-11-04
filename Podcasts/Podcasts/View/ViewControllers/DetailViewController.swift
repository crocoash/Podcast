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
    private var image : URL!
    private var episode : String!
    private var collection : String!
    private var episodeDescription : String!
    
    weak var delegate: DetailViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureGestures()
        setupView()
        self.view.addMyGestureRecognizer(self, type: .tap(), selector: #selector(dismissOnScreenTap))
    }
    
    func receivePodcastInfoAndIndex(index: Int, image url: URL, episode: String, collection: String, episodeDescription: String) {
        self.index = index
        self.image = url
        self.episode = episode
        self.collection = collection
        self.episodeDescription = episodeDescription
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
//        episodeImage.load(url: image)
        episodeName.text = episode
        collectionName.text = collection
        descriptionTextView.text = episodeDescription
    }
    
    private func configureGestures() {
        view.addMyGestureRecognizer(self, type: .screenEdgePanGestureRecognizer(directions: [.right]), selector: #selector(dismissOnScreenTap))
    }
}
