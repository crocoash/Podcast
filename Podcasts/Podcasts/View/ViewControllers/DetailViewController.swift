//
//  DetailViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit

protocol DetailViewControllerDelegate: AnyObject {
    func detailViewController(sender: DetailViewController, playButtonDidTouchFor podcast: Podcast)
}

class DetailViewController: UIViewController {
    
    @IBOutlet private weak var episodeImage: UIImageView!
    @IBOutlet private weak var episodeName: UILabel!
    @IBOutlet private weak var collectionName: UILabel!
    @IBOutlet private weak var descriptionTextView: UITextView!
    
    private var index : Int!
    private var image : UIImage!
    private var episode : String!
    private var collection : String!
    private var episodeDescription : String!
    
    weak var delegate: DetailViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    @IBAction private func listenButtonOnTouchUpInside(_ sender: UIButton) {
        //delegate?.detailViewController(sender: self, playButtonDidTouchFor: <#T##Podcast#>)
    }
    
    func receivePodcastInfoAndIndex(index: Int, image: UIImageView, episode: String, collection: String, episodeDescription: String) {
        self.index = index
        self.image = image.image
        self.episode = episode
        self.collection = collection
        self.episodeDescription = episodeDescription
    }
    
    private func setupView(){
        episodeImage.image = image
        episodeName.text = episode
        collectionName.text = collection
        descriptionTextView.text = episodeDescription
    }
    
}
