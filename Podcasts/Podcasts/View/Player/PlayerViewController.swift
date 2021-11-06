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
    
    @IBOutlet private weak var progressSlider: UISlider!
    
    private var player: AVPlayer = AVPlayer()
    
    private var podcasts: [Podcast] = []
    
    var currentPodcast: Podcast? { !podcasts.isEmpty ? podcasts[index] : nil }
    
    lazy private var bigPlayerVC: BigPlayerViewController = {
        $0.delegate = self
        $0.setUP(player: player)
        $0.modalPresentationStyle = .fullScreen
        return $0
    }(BigPlayerViewController.loadFromXib())
    
    private var isLast: Bool { index == (podcasts.count - 1) }
    private var isFirst: Bool { index == 0 }
    
    private var index: Int = 0 {
        didSet {
            startPlay()
            configureUI()
        }
    }
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureGesture()
    }
    
    // MARK: - Actions
    @IBAction func playPauseTouchUpInside(_ sender: UIButton) {
        playStop()
    }
    
    @objc func respondToSwipe(gesture: UISwipeGestureRecognizer) {
        present(bigPlayerVC, animated: true)
        bigPlayerVC.upDateUI(with: currentPodcast, isFirst: isFirst, isLast: isLast)
    }
    
    func play(podcasts: [Podcast], at index: Int) {
        self.podcasts = podcasts
        self.index = index
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
    }
    
    private func configureGesture() {
        view.addMyGestureRecognizer(self, type: .swipe(directions: [.up]), selector: #selector(respondToSwipe))
        view.addMyGestureRecognizer(self, type: .tap(1), selector: #selector(respondToSwipe))
    }
    
    private func startPlay() {
        guard
            let podcast = currentPodcast,
            let string = podcast.episodeUrl,
            let url = URL(string: string)
        else { return }
        
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player.play()
    }
    
    private func startPlayCurrentPodcast(bigPlayerViewController: BigPlayerViewController) {
        startPlay()
        bigPlayerViewController.upDateUI(with: currentPodcast, isFirst: isFirst, isLast: isLast)
    }
}

// MARK: - BigPlayerViewControllerDelegate
extension PlayerViewController: BigPlayerViewControllerDelegate {
    
    func bigPlayerViewControllerDidSelectStopButton(_ bigPlayerViewController: BigPlayerViewController) {
        playStop()
    }
    
    func bigPlayerViewControllerDidSelectNextTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        index += 1
        
        startPlayCurrentPodcast(bigPlayerViewController: bigPlayerViewController)
    }
    
    func bigPlayerViewControllerDidSelectPreviewsTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        index -= 1
        
        startPlayCurrentPodcast(bigPlayerViewController: bigPlayerViewController)
    }
}
