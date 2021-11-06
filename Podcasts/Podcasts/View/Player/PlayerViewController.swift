//
//  NewPlayerViewController.swift
//  test
//
//  Created by mac on 30.10.2021.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var podcastImageView: UIImageView!
    @IBOutlet private weak var podcastNameLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    private var player: AVPlayer = AVPlayer()
    
    private var podcasts: [Podcast] = []
    
    private var pauseImage = UIImage(systemName: "pause.fill")
    private var playImage = UIImage(systemName: "play.fill")
                   
    var currentPodcast: Podcast? { !podcasts.isEmpty ? podcasts[index] : nil }
    
    lazy private var bigPlayerVC: BigPlayerViewController = {
        $0.delegate = self
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
        guard let pauseImage = pauseImage, let playImage = playImage else { return }
       
        bigPlayerVC.setPlayStopButton(with: player.rate != 0 ? pauseImage : playImage)
        bigPlayerVC.upDateUI(with: currentPodcast, isFirst: isFirst, isLast: isLast)
    }
    
    func play(podcasts: [Podcast], at index: Int) {
        self.podcasts = podcasts
        self.index = index
        guard let pauseImage = pauseImage else { return }
        playPauseButton.setImage(pauseImage, for: .normal)
    }
}

//MARK: - Private methods
extension PlayerViewController {
    
    private func playStop() {
        if player.rate == 0 {
            guard let pauseImage = pauseImage else { return }
            player.play()
            playPauseButton.setImage(pauseImage, for: .normal)
            bigPlayerVC.setPlayStopButton(with: pauseImage)
        } else {
            guard let playImage = playImage else { return }
            player.pause()
            playPauseButton.setImage(playImage, for: .normal)
            bigPlayerVC.setPlayStopButton(with: playImage)
        }
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
        
        player = AVPlayer(url: url)
        player.addPeriodicTimeObserver(
            forInterval: CMTimeMakeWithSeconds(1/30.0, preferredTimescale: Int32(NSEC_PER_SEC)),
            queue: nil) { [weak self] time in
                guard let self = self, let duaration = self.player.currentItem?.duration else { return }
                let duration = CMTimeGetSeconds(duaration)
                self.progressView.progress = Float((CMTimeGetSeconds(time) / duration))
                
                
                
        }
        
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
