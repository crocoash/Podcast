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
    @IBOutlet private weak var autorNameLabel: UILabel!
    @IBOutlet private weak var progressSlider: UISlider!
    
    lazy private var bigPlayerVC: BigPlayerViewController = {
        $0.delegate = self
        $0.modalPresentationStyle = .fullScreen
        $0.setUP(podcast: podcasts[current])
        return $0
    }(BigPlayerViewController.loadFromXib())
    
    private var player: AVPlayer = AVPlayer()
    private var current: Int = 0
    
    private var podcasts: [Podcast] = []
 
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGesture()
        addPlayerTimeObservers()
    }
    
    @IBAction func playPauseTouchUpInside(_ sender: UIButton) {
        playStop()
    }
    
    @objc func respondToSwipe(gesture: UISwipeGestureRecognizer) {
        present(bigPlayerVC, animated: true)
    }
}

//MARK: - Private methods
extension PlayerViewController {
    
    private func playStop() {
        player.rate == 0 ? player.play() : player.pause()
    }
    
    private func configureGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipe))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        view.addMyGestureRecognizer(self, type: .tap(1), selector: #selector(respondToSwipe))
    }
    
    private func addPlayerTimeObservers() {
    
    }
    
    private func startPlay(podcast: Podcast) {
        guard let string = podcast.episodeUrl, let url = URL(string: string) else { return }
        player = AVPlayer(url: url)
        player.play()
    }
}

// MARK: - SearchViewControllerDelegate
extension PlayerViewController: SearchViewControllerDelegate {
    func searchViewController(_ searchViewController: SearchViewController, play podcasts: [Podcast], at index: Int) {
        self.podcasts = podcasts
        current = index
        startPlay(podcast: podcasts[index])
    }
}

// MARK: - PlaylistTableViewControllerDelegate
extension PlayerViewController : PlaylistTableViewControllerDelegate {
    func playlistTableViewController(_ playlistTableViewController: PlaylistTableViewController, play podcasts: [Podcast], at index: Int) {
        self.podcasts = podcasts
        current = index
        startPlay(podcast: podcasts[index])
    }
}

// MARK: - BigPlayerViewControllerDelegate
extension PlayerViewController: BigPlayerViewControllerDelegate {
    
    func bigPlayerViewControllerDidSelectStopButton(_ bigPlayerViewController: BigPlayerViewController) {
        playStop()
    }
    
    func bigPlayerViewControllerDidSelectNextTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        current += 1
        let podcast = podcasts[current]
        startPlay(podcast: podcast)
        bigPlayerViewController.upDateUI(with: podcast)
    }
    
    func bigPlayerViewControllerDidSelectPreviewsTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        current -= 1
        let podcast = podcasts[current]
        startPlay(podcast: podcast)
        bigPlayerViewController.upDateUI(with: podcast)
    }
}
