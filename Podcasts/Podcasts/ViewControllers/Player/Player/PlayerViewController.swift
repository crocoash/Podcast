//
//  NewPlayerViewController.swift
//  test
//
//  Created by mac on 30.10.2021.
//

import UIKit
import AVFoundation
import CoreData

class PlayerViewController: UIViewController {
    
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var podcastImageView: UIImageView!
    @IBOutlet private weak var podcastNameLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var progressView: UIProgressView!
    
    private(set) var player: AVPlayer = AVPlayer()
    lazy var bigPlayerVC: BigPlayerViewController = configureBigPlayer()
    
    private var podcasts: [Podcast] = []
    private(set) var currentPodcast: (podcast:Podcast, index: Int)?
    
    private var playStopImage: UIImage { player.rate == 0 ? playImage : pauseImage }
    private var workItem: DispatchWorkItem?
    private var observe: Any?
    
    //MARK: - Settings
    private var pauseImage = UIImage(systemName: "pause.fill")!
    private var playImage = UIImage(systemName: "play.fill")!
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGesture()
        addObserverForEndTrack()
        updateaAllPlayers(with: currentPodcast?.podcast)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Methods
    func setPlayer(player: AVPlayer) {
        self.player = player
    }
    
    func startPlay(at index: Int, at moment: Double? = nil, podcasts: [Podcast]) {
        let podcast = podcasts[index]
        self.podcasts = podcasts
        self.currentPodcast = (podcast, index)
        startPlay(podcast: podcast, at: moment)
    }
    
    // MARK: - Actions
    @objc func playNextTrackOfTheEndObserver() {
        playNextPodcast()
    }
    
    @IBAction func playOrPause() {
        player.rate == 0 ? player.play() : player.pause()
        updateaAllPlayers(with: currentPodcast?.podcast)
    }
    
    @objc func respondToSwipe(gesture: UIGestureRecognizer) {
        present(bigPlayerVC, animated: true)
        bigPlayerVC.isPresented = true
        if let podcast = currentPodcast?.podcast {
            bigPlayerVC.upDateUI(with: podcast, isFirst: isFirstPodcast, isLast: isLastPodcast, playStopButton: playStopImage)
        }
    }
}

//MARK: - Private methods
extension PlayerViewController {
    
    private func configureBigPlayer() -> BigPlayerViewController {
        let bigPlayerVC = BigPlayerViewController.loadFromXib()
        bigPlayerVC.delegate = self
        bigPlayerVC.modalPresentationStyle = .fullScreen
        return bigPlayerVC
    }
    
    private func configureGesture() {
        addMyGestureRecognizer(self, type: .swipe(directions: [.up]), #selector(respondToSwipe))
        addMyGestureRecognizer(self, type: .tap()                   , #selector(respondToSwipe))
    }
    
    private func addObserverForEndTrack() {
        NotificationCenter.default.addObserver(self, selector: #selector(playNextTrackOfTheEndObserver), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    private var isLastPodcast: Bool {
        return (currentPodcast?.index ?? (Int.max - 1)) + 1 == podcasts.count
    }
    
    private var isFirstPodcast: Bool {
        return currentPodcast?.index ?? 1 == 0
    }
    
    private func startPlay(podcast: Podcast, at moment: Double? = nil) {
        activityIndicator.startAnimating()
        /// if it is not likedMoment set current podcast with Index for next or previus playing
        if !podcasts.isEmpty, let index = podcasts.firstIndex(of: podcast) {
            currentPodcast = (podcast, index)
        }
        player.pause()
        updateaAllPlayers(with: podcast)
        workItem?.cancel()
        
        if observe == nil {
            addTimeObserve()
        }
        
        guard let episodeUrl = podcast.episodeUrl.url else { return }
        let url = FavoriteDocument.shared.isDownload(podcast: podcast) ? episodeUrl.localPath : episodeUrl
        
        let requestWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            let item = AVPlayerItem(url: url)
            self.player.replaceCurrentItem(with: item)
            self.player.play()
            
            if let moment = moment { self.playerSeek(to: moment) }
            
            DispatchQueue.main.async {
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate  {
                    sceneDelegate.videoViewController = self
                }
                self.updateaAllPlayers(with: podcast)
            }
        }
        
        workItem = requestWorkItem
        
        DispatchQueue.global().asyncAfter(deadline: .now(), execute: requestWorkItem)
    }
    
    private func playerSeek(to seconds: Double) {
        self.player.seek(to: CMTime(seconds: seconds, preferredTimescale: 60))
    }
    
    private func playNextPodcast() {
        guard !podcasts.isEmpty, let currentPodcast = currentPodcast, !isLastPodcast else { return }
        
        let podcast = podcasts[currentPodcast.index + 1]
        let index = currentPodcast.index + 1
        self.currentPodcast = (podcast,index)
        startPlay(podcast: podcast)
    }
    
    private func playPreviewsPodcast() {
        guard !podcasts.isEmpty, let currentPodcast = currentPodcast, !isFirstPodcast else { return }
        
        let podcast = podcasts[currentPodcast.index - 1]
        let index = currentPodcast.index - 1
        self.currentPodcast = (podcast,index)
        startPlay(podcast: podcast)
    }
    
    private func addTimeObserve() {
        observe = player.addPeriodicTimeObserver( forInterval: CMTimeMakeWithSeconds(1/60, preferredTimescale: Int32(NSEC_PER_SEC)),
                                                  queue: .main ) { [weak self] time in
            guard
                let self = self,
                let duration = self.player.currentItem?.duration,
                let currentItem = self.player.currentItem
            else { return }
            
            /// update small player
            self.progressView.progress = Float((CMTimeGetSeconds(time) / CMTimeGetSeconds(duration)))
            
            if !self.activityIndicator.isHidden { self.activityIndicator.stopAnimating() }
            let currentTime = Float(self.player.currentTime().seconds)
            if self.bigPlayerVC.isPresented {
                self.bigPlayerVC.upDateProgressSlider(currentTime: currentTime, duration: Float(currentItem.asset.duration.seconds))
            }
        }
    }
    
    ///_____________________________
    private func updateaAllPlayers(with podcast: Podcast?) {
        guard let podcast = podcast else { return }
        updateSmallPlayer(with: podcast)
        updateBigBlayer(with: podcast)
    }
    
    private func updateBigBlayer(with podcast: Podcast) {
        if bigPlayerVC.isPresented {
            bigPlayerVC.upDateUI(with: podcast, isFirst: isFirstPodcast, isLast: isLastPodcast, playStopButton: playStopImage)
            bigPlayerVC.updatePlayButton(playButtonImage: playStopImage)
        }
    }
    
    private func updateSmallPlayer(with podcast: Podcast) {
        DataProvider().downloadImage(string: podcast.artworkUrl600) { [weak self] image in
            self?.podcastImageView.image = image
        }
        playPauseButton.setImage(playStopImage, for: .normal)
        podcastNameLabel.text = podcast.trackName
    }
    
    private func removeTimeObserve() {
        player.removeTimeObserver(observe!)
        observe = nil
    }
}

// MARK: - BigPlayerViewControllerDelegate
extension PlayerViewController: BigPlayerViewControllerDelegate {
    
    func bigPlayerViewController(_ bigPlayerViewController: BigPlayerViewController, didLikeThis moment: Double) {
        guard let podcast = currentPodcast?.podcast else { return }
        _ = LikedMoment(podcast: podcast, moment: moment, id: podcast.id!)
        DataStoreManager.shared.viewContext.mySave()
        FirebaseDatabase.shared.saveLikedMoment()
    }
    
    func bigPlayerViewController(_ bigPlayerViewController: BigPlayerViewController, didChangeCurrentTime value: Double) {
        player.seek(to: CMTime(seconds: value, preferredTimescale: 60))
    }
    
    func bigPlayerViewControllerDidSelectPlayStopButton(_ bigPlayerViewController: BigPlayerViewController) {
        playOrPause()
    }
    
    func bigPlayerViewControllerDidSelectNextTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        removeTimeObserve()
        bigPlayerViewController.refreshInfo()
        playNextPodcast()
    }
    
    func bigPlayerViewControllerDidSelectPreviewsTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        removeTimeObserve()
        bigPlayerViewController.refreshInfo()
        playPreviewsPodcast()
    }
    
    func bigPlayerViewController (_ bigPlayerViewController: BigPlayerViewController, didAddCurrentTimeBy value: Double) {
        guard let currentTime = player.currentItem?.currentTime().seconds else { return }
        playerSeek(to: currentTime + value)
    }
}
