//
//  NewPlayerViewController.swift
//  test
//
//  Created by mac on 30.10.2021.
//

import UIKit
import AVFoundation

protocol PlayerViewControllerDelegate: AnyObject {
    func updateTrackTimeWith(duration: Float, currentTime: Float)
}

class PlayerViewController: UIViewController {
    
    @IBOutlet private weak var podcastImageView: UIImageView!
    @IBOutlet private weak var podcastNameLabel: UILabel!
    @IBOutlet private weak var authorNameLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    weak var delegate: PlayerViewControllerDelegate?
    
    private var player: AVPlayer = AVPlayer()
    private var podcasts: [Podcast] = []
    private var currentPodcast: Podcast? { !podcasts.isEmpty ? podcasts[index] : nil }
    
    private var timeObserver: Any?
    
    lazy private var bigPlayerVC: BigPlayerViewController = {
        $0.delegate = self
        $0.modalPresentationStyle = .fullScreen
        $0.setUP(podcast: currentPodcast, isLast: isLast, isFirst: index == 0)
        return $0
    }(BigPlayerViewController.loadFromXib())
    
    
    private var isLast: Bool { index == (podcasts.count - 1) }
    private var isFirst: Bool { index == 0 }
    
    private var index: Int = 0 {
        didSet {
            configureUI()
            bigPlayerVC.setUP(podcast: currentPodcast, isLast: index == (podcasts.count - 1), isFirst: index == 0)
        }
    }
        
   // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGesture()
        progressView.progress = 0.0
    }
    
    // MARK: - Actions
    @IBAction func playPauseTouchUpInside(_ sender: UIButton) {
        playStop()
    }
    
    @objc func respondToSwipe(gesture: UISwipeGestureRecognizer) {
        self.delegate = bigPlayerVC
        present(bigPlayerVC, animated: true)
    }
}

//MARK: - Private methods
extension PlayerViewController {
    
    private func playStop() {
        player.rate == 0 ? player.play() : player.pause()
    }
    
    private func configureUI() {
        podcastImageView.load(string: currentPodcast?.artworkUrl600)
        podcastNameLabel.text = currentPodcast?.trackName ?? "No Track Name"
        authorNameLabel.text = currentPodcast?.country
    }
    
    private func configureGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipe))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        view.addMyGestureRecognizer(self, type: .tap(1), selector: #selector(respondToSwipe))
    }
    
    @objc private func updateTrackProgress() {
        guard player.currentItem?.status == .readyToPlay else { return }
        guard player.currentItem!.duration >= CMTime.zero else { return }
        guard let trackDuration = player.currentItem?.duration.seconds else { return }
        let currentTime = Float(player.currentTime().seconds)
        progressView.progress = currentTime/Float(trackDuration)
        delegate?.updateTrackTimeWith(duration: Float(trackDuration), currentTime: currentTime)
    }
    
    private func startPlay(podcast: Podcast? ) {
        guard
            let podcast = podcast,
            let string = podcast.episodeUrl,
            let url = URL(string: string)
        else { return }
        player = AVPlayer(url: url)
        player.play()
        var timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTrackProgress), userInfo: nil, repeats: true)
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
    func theNewSlider(valueIs: Float) {
        player.seek(to: CMTime(seconds: Double(valueIs), preferredTimescale: 60))
    }
    
    func bigPlayerViewControllerDidSelectStopButton(_ bigPlayerViewController: BigPlayerViewController) {
        playStop()
    }
    
    func bigPlayerViewControllerDidSelectNextTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        index += 1
        startPlay(podcast: currentPodcast)
        bigPlayerViewController.upDateUI(with: currentPodcast)
        
    }
    
    func bigPlayerViewControllerDidSelectPreviewsTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        index -= 1
        startPlay(podcast: currentPodcast)
        bigPlayerViewController.upDateUI(with: currentPodcast)
    }
    
}
