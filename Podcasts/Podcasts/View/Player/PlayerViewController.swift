//
//  NewPlayerViewController.swift
//  test
//
//  Created by mac on 30.10.2021.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    @IBOutlet private weak var podcastImageView: UIImageView!
    @IBOutlet private weak var podcastNameLabel: UILabel!
    @IBOutlet private weak var authorNameLabel: UILabel!
    
    @IBOutlet private weak var progressSlider: UISlider!
    
    private var player: AVPlayer = AVPlayer()
    
    private var podcasts: [Podcast] = []
    
    private var currentPodcast: Podcast? { !podcasts.isEmpty ? podcasts[index] : nil }
    
    lazy private var bigPlayerVC: BigPlayerViewController = {
        $0.delegate = self
        $0.modalPresentationStyle = .fullScreen
        return $0
    }(BigPlayerViewController.loadFromXib())
    
    
    private var isLast: Bool { index == (podcasts.count - 1) }
    private var isFirst: Bool { index == 0 }
    
    private var index: Int = 0 {
        didSet {
            configureUI()
        }
    }
        
   // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureGesture()
        addPlayerTimeObservers()
    }
    
    // MARK: - Actions
    @IBAction func playPauseTouchUpInside(_ sender: UIButton) {
        playStop()
    }
    
    @objc func respondToSwipe(gesture: UISwipeGestureRecognizer) {
        present(bigPlayerVC, animated: true)
        bigPlayerVC.upDateUI(with: currentPodcast, isFirst: isFirst, isLast: isLast)
    }
}

//MARK: - Private methods
extension PlayerViewController {
    
    private func playStop() {
        player.rate == 0 ? player.play() : player.pause()
    }
    
    private func configureUI() {
        podcastImageView.load(string: currentPodcast?.artworkUrl600)
        podcastNameLabel.text = currentPodcast?.trackName
        authorNameLabel.text = currentPodcast?.country
    }
    
    private func configureGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipe))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        view.addMyGestureRecognizer(self, type: .tap(1), selector: #selector(respondToSwipe))
    }
    
    private func addPlayerTimeObservers() {
    
    }
    
    private func startPlay(podcast: Podcast? ) {
        guard
            let podcast = podcast,
            let string = podcast.episodeUrl,
            let url = URL(string: string)
        else { return }
        
        player = AVPlayer(url: url)
        player.play()
    }
}

// MARK: - SearchViewControllerDelegate
extension PlayerViewController: SearchViewControllerDelegate {
    
    func searchViewController(_ searchViewController: SearchViewController, play podcasts: [Podcast], at index: Int) {
        self.podcasts = podcasts
        self.index = index
        startPlay(podcast: currentPodcast)
    }
}

// MARK: - PlaylistTableViewControllerDelegate
extension PlayerViewController : PlaylistTableViewControllerDelegate {

    func playlistTableViewController(_ playlistTableViewController: PlaylistTableViewController, play podcasts: [Podcast], at index: Int) {
        self.podcasts = podcasts

        self.index = index
        
        startPlay(podcast: currentPodcast)
    }
}

// MARK: - BigPlayerViewControllerDelegate
extension PlayerViewController: BigPlayerViewControllerDelegate {
    
    func bigPlayerViewControllerDidSelectStopButton(_ bigPlayerViewController: BigPlayerViewController) {
        playStop()
    }
    
    func bigPlayerViewControllerDidSelectNextTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        index += 1
       
        startPlay(podcast: currentPodcast)
        bigPlayerViewController.upDateUI(with: currentPodcast, isFirst: isFirst, isLast: isLast)
    }
    
    func bigPlayerViewControllerDidSelectPreviewsTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        index -= 1
      
        startPlay(podcast: currentPodcast)
        bigPlayerViewController.upDateUI(with: currentPodcast, isFirst: isFirst, isLast: isLast)
    }
}
