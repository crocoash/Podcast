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
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var progressView: UIProgressView!
    
    private var player: AVPlayer = AVPlayer()
    
    lazy private var bigPlayerVC = createBigPlayer()
    
    private var podcasts: [Podcast] = []
    
    private var playStopImage: UIImage? { player.rate == 0 ? playImage : pauseImage }
    private var isLastPodcast: Bool { index == (podcasts.count - 1) }
    private var isFirstPodcast: Bool { index == 0 }
    
    var workItem: DispatchWorkItem?
    
    var currentPodcast: Podcast? { !podcasts.isEmpty ? podcasts[index] : nil }
    
    private var observe: Any?
    private var index: Int = 0 {
        didSet {
            activityIndicator.startAnimating()
            upDateUI()
            player.pause()
            startPlay()
        }
    }
    
    //MARK: - Settings
    private var pauseImage = UIImage(systemName: "pause.fill")
    private var playImage = UIImage(systemName: "play.fill")
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        upDateUI()
        configureGesture()
        addObserverForEndTrack()
    }
    
    //MARK: - Methods
    func play(podcasts: [Podcast], at index: Int) {
        self.podcasts = podcasts
        self.index = index
    }
    
    // MARK: - Actions
    @objc func endTrack() {
        if !isLastPodcast { index += 1 }
    }
    
    @IBAction func playPauseTouchUpInside(_ sender: UIButton) {
        playStopPlayer()
    }
    
    @objc func respondToSwipe(gesture: UIGestureRecognizer) {

        guard let playStopImage = playStopImage,
              let currentPodcast = currentPodcast
        else { return }
        
        present(bigPlayerVC, animated: true)

        bigPlayerVC.setPlayStopButton(with: playStopImage)
        bigPlayerVC.upDateUI(
            with: currentPodcast,
            isFirst: isFirstPodcast,
            isLast: isLastPodcast
        )
    }
}

//MARK: - Private methods
extension PlayerViewController {
    
    private func playStopPlayer() {
        player.rate == 0 ? player.play() : player.pause()
        
        guard let playStopImage = playStopImage else { return }
        playPauseButton.setImage(playStopImage, for: .normal)
    }
    
    private func startPlay() {
        guard let podcast = currentPodcast,
              let string = podcast.episodeUrl,
              let url = URL(string: string) else { return }
        
        workItem?.cancel()
        
        let requestWorkItem = DispatchWorkItem {
            let item = AVPlayerItem(url: podcast.isDownLoad ? url.locaPath : url)
            self.player.replaceCurrentItem(with: item)
            self.player.play()
        }
        
        workItem = requestWorkItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: requestWorkItem)
        
        self.playPauseButton.setImage(self.pauseImage, for: .normal)
    }
    
    private func addTimeObserve() {
        observe = player.addPeriodicTimeObserver(
            forInterval: CMTimeMakeWithSeconds(1/60, preferredTimescale: Int32(NSEC_PER_SEC)),
            queue: .main
        ) { [weak self] time in
            
            guard
                let self = self,
                let duaration = self.player.currentItem?.duration,
                let currentItem = self.player.currentItem
            else { return }
            
            let duration = CMTimeGetSeconds(duaration)
            self.progressView.progress = Float((CMTimeGetSeconds(time) / duration))
            
            if !self.activityIndicator.isHidden { self.activityIndicator.stopAnimating() }

            let currentTime = Float(self.player.currentTime().seconds)
            
            if self.bigPlayerVC.isPresented {
                self.bigPlayerVC.upDateProgressSlider(currentTime: currentTime, currentItem: Float(currentItem.asset.duration.seconds))
            }
        }
    }
    
    private func createBigPlayer() -> BigPlayerViewController {
        bigPlayerVC = BigPlayerViewController.loadFromXib()
        bigPlayerVC.delegate = self
        bigPlayerVC.modalPresentationStyle = .fullScreen
        
        return bigPlayerVC
    }
    
    private func upDateUI() {
        guard let currentPodcast = self.currentPodcast else { return }
        
        DataProvider().downloadImage(string: currentPodcast.artworkUrl600) { [weak self] image in
            self?.podcastImageView.image = image
        }
        
        playPauseButton.setImage(pauseImage, for: .normal)
        podcastNameLabel.text = currentPodcast.trackName
        
        if !self.bigPlayerVC.isPresented { return }
        
        bigPlayerVC.upDateUI(
            with: currentPodcast,
            isFirst: isFirstPodcast,
            isLast: isLastPodcast
        )
    }
    
    private func addObserverForEndTrack() {
        NotificationCenter.default.addObserver(self, selector: #selector(endTrack), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        addTimeObserve()
    }
    
    private func configureGesture() {
        view.addMyGestureRecognizer(self, type: .swipe(directions: [.up]), selector: #selector(respondToSwipe))
        view.addMyGestureRecognizer(self, type: .tap(1), selector: #selector(respondToSwipe))
    }
    
    private func nextPodcast() {
        index += 1
    }
    
    private func previewsPodcast() {
        index -= 1
    }
}

// MARK: - BigPlayerViewControllerDelegate
extension PlayerViewController: BigPlayerViewControllerDelegate {
    
    func bigPlayerViewController(_ bigPlayerViewController: BigPlayerViewController, didChangeCurrentTime value: Double) {
        player.seek(to: CMTime(seconds: value, preferredTimescale: 60))
    }
    
    func bigPlayerViewControllerDidSelectStopButton(_ bigPlayerViewController: BigPlayerViewController) {
        playStopPlayer()
        
        guard let playStopImage = playStopImage else { return }
        bigPlayerViewController.setPlayStopButton(with: playStopImage)
    }
    
    func bigPlayerViewControllerDidSelectNextTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        nextPodcast()
    }
    
    func bigPlayerViewControllerDidSelectPreviewsTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        previewsPodcast()
    }
    
    func bigPlayerViewController (_ bigPlayerViewController: BigPlayerViewController, didAddCurrentTimeBy value: Double) {
        guard let currentItem = player.currentItem else { return }
            self.player.seek(to: currentItem.currentTime() + CMTime(seconds: value, preferredTimescale: 60))
    }
}
