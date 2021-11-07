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
    
    private var playStopImage: UIImage? {
        player.rate != 0 ? pauseImage : playImage
    }
                   
    var currentPodcast: Podcast? { !podcasts.isEmpty ? podcasts[index] : nil }
    
    lazy private var bigPlayerVC = createBigPlayer()
    
    private var isLastPodcast: Bool { index == (podcasts.count - 1) }
    private var isFirstPodcast: Bool { index == 0 }
    
    private var index: Int = 0 {
        didSet {
            startPlay()
            configureUI()
            if bigPlayerVC.isPresented {
                bigPlayerVC.upDateUI(currentItem: player.currentItem, with: currentPodcast, isFirst: isFirstPodcast, isLast: isLastPodcast)
            }
        }
    }
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureGesture()
       
    }
    
    @objc func endTrack() {
        if !isLastPodcast { index += 1 }
    }
    
    // MARK: - Actions
    @IBAction func playPauseTouchUpInside(_ sender: UIButton) {
        playStop()
    }
    
    @objc func respondToSwipe(gesture: UIGestureRecognizer) {
        
        guard
            let playStopImage = playStopImage,
            let currentItem = player.currentItem,
            player.currentItem?.status == .readyToPlay
        else { return }
        
        present(bigPlayerVC, animated: true)
        
        addTimeObserve()
        bigPlayerVC.setPlayStopButton(with: playStopImage)
        bigPlayerVC.upDateUI(currentItem: currentItem ,with: currentPodcast, isFirst: isFirstPodcast, isLast: isLastPodcast)
    }
    
    func play(podcasts: [Podcast], at index: Int) {
        self.podcasts = podcasts
        self.index = index
    }
}

//MARK: - Private methods
extension PlayerViewController {
    
    private func playStop() {
        if player.rate == 0 {
            guard let pauseImage = pauseImage else { return }
            player.play()
            playPauseButton.setImage(pauseImage, for: .normal)
        } else {
            guard let playImage = playImage else { return }
            player.pause()
            playPauseButton.setImage(playImage, for: .normal)
        }
    }
    
    private func addTimeObserve() {
        player.addPeriodicTimeObserver(
            forInterval: CMTimeMakeWithSeconds(5, preferredTimescale: Int32(NSEC_PER_SEC)),
            queue: nil) { [weak self] time in
                
                guard let self = self else { return }
                let currentTime = Float(self.player.currentTime().seconds)
                self.bigPlayerVC.upDateProgressSlider(currentTime: currentTime)
            }
    }
    
    private func createBigPlayer() -> BigPlayerViewController {
        bigPlayerVC = BigPlayerViewController.loadFromXib()
        bigPlayerVC.delegate = self
        bigPlayerVC.modalPresentationStyle = .fullScreen
        
        return bigPlayerVC
    }
    
    private func configureUI() {
        podcastImageView.load(string: currentPodcast?.artworkUrl600)
        podcastNameLabel.text = currentPodcast?.trackName
        NotificationCenter.default.addObserver(self, selector: #selector(endTrack), name: .AVPlayerItemDidPlayToEndTime, object: nil)
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
            queue: nil
        ) { [weak self] time in
            
            guard
                let self = self,
                let duaration = self.player.currentItem?.duration
            else { return }
            
            let duration = CMTimeGetSeconds(duaration)
            self.progressView.progress = Float((CMTimeGetSeconds(time) / duration))
        }
        
        guard let playStopImage = playStopImage else { return }
        playPauseButton.setImage(playStopImage, for: .normal)
        
        player.play()
    }
}

// MARK: - BigPlayerViewControllerDelegate
extension PlayerViewController: BigPlayerViewControllerDelegate {
    func bigPlayerViewController(_ bigPlayerViewController: BigPlayerViewController, didChangeProgressSlider value: Double) {
        
        player.seek(to: CMTime(seconds: value, preferredTimescale: 60))
//        player.removeTimeObserver(player.timeObserver)
    }
    
    func bigPlayerViewControllerDidSelectStopButton(_ bigPlayerViewController: BigPlayerViewController) {
        playStop()
        guard let pauseImage = pauseImage, let playImage = playImage else { return }
       
        bigPlayerViewController.setPlayStopButton(with: player.rate != 0 ? pauseImage : playImage)
    }
    
    func bigPlayerViewControllerDidSelectNextTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        index += 1
    }
    
    func bigPlayerViewControllerDidSelectPreviewsTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        index -= 1
    }
}
