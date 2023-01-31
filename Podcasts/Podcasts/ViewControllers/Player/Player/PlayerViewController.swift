//
//  NewPlayerViewController.swift
//  test
//
//  Created by mac on 30.10.2021.
//

import UIKit
import AVFoundation
import CoreData
import MediaPlayer

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
    
    private var playStopImage: UIImage { player.rate == 0 && player.status == .readyToPlay ? playImage : pauseImage }
    private var observe: Any?
    
    //MARK: - Settings
    private var pauseImage = UIImage(systemName: "pause.fill")!
    private var playImage = UIImage(systemName: "play.fill")!
    
    private var mpRemoteCommandCenter: MPRemoteCommandCenter?
    private var mPNowPlayingInfoCenter: MPNowPlayingInfoCenter?
    
    private var isLastPodcast: Bool { (currentPodcast?.index ?? (Int.max - 1)) + 1 == podcasts.count }
    private var isFirstPodcast: Bool { currentPodcast?.index ?? 1 == 0 }
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGesture()
        addObserverForEndTrack()
        updateAllPlayers(with: currentPodcast?.podcast)
        configureMPRemoteCommandCenter ()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        mpRemoteCommandCenter = nil
    }
    
    //MARK: - Methods
    func setPlayer(player: AVPlayer) {
        self.player = player
    }
    
    func startPlay(at index: Int, at moment: Double? = nil, playlist: [Podcast]) {
        let podcast = playlist[index]
        self.podcasts = playlist
        self.currentPodcast = (podcast, index)
        startPlay(podcast: podcast, at: moment)
    }
    
    // MARK: - Actions
    @objc func playNextTrackOfTheEndObserver() {
        playNextPodcast()
    }
    
    @IBAction func playOrPause() {
        player.rate == 0 ? player.play() : player.pause()
        updatePlayStopButton()
    }
    
    private func updatePlayStopButton() {
        playPauseButton.setImage(playStopImage, for: .normal)
        bigPlayerVC.updatePlayStopButton(with: playStopImage)
    }
    
    @objc func respondToSwipe(gesture: UIGestureRecognizer) {
        present(bigPlayerVC, animated: true)
        bigPlayerVC.isPresented(true)
        updateBigBlayer(with: currentPodcast?.podcast)
    }
    
    @objc func playerSeek(to seconds: Double) {
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
    
    private func startPlay(podcast: Podcast, at moment: Double? = nil) {
        removeTimeObserve()
        player.replaceCurrentItem(with: nil)
        refreshAllPlayers()
        activityIndicator.startAnimating()
        
        guard let episodeUrl = podcast.episodeUrl.url else { return }
        let url = FavoriteDocument.shared.isDownload(podcast) ? episodeUrl.localPath : episodeUrl
//
//        let requestWorkItem = DispatchWorkItem { [weak self] in
//            guard let self = self else { return }
            
            let item = AVPlayerItem(url: url)
            self.player.replaceCurrentItem(with: item)
            if let moment = moment { self.playerSeek(to: moment) }
        self.player.play()
            
//            DispatchQueue.main.async {
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate  {
                    sceneDelegate.videoViewController = self
                }
                self.addTimeObserve()
                updateAllPlayers(with: podcast)

//            }
//        }
        
        mPNowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        //
//         let mPMediaItemArtwork = MPMediaItemArtwork(boundsSize: CGSize(width: 200, height: 100)) { [weak self] size in
//            return self.podcastImageView.image
//        }
//        
//        if let mPMediaItemArtwork = mPMediaItemArtwork {
//            mPNowPlayingInfoCenter?.nowPlayingInfo = [
//                MPMediaItemPropertyTitle: podcast.trackName ?? "No track name",
//                MPMediaItemPropertyArtwork: mPMediaItemArtwork
//            ]
//        }
        
//        DispatchQueue.global().asyncAfter(deadline: .now(), execute: requestWorkItem)
         
    }
    
    
    private func addTimeObserve() {
        
        observe = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/60, preferredTimescale: Int32(NSEC_PER_SEC)),
                                                 queue: .main ) { [weak self] time in
            guard
                let self = self,
                let duration = self.player.currentItem?.duration.seconds
            else { return }
            
            let currentTime = Float(self.player.currentTime().seconds)

            if self.bigPlayerVC.isPresented {
                self.bigPlayerVC.upDateProgressSlider(currentTime: currentTime, duration: Float(duration))
            }
            self.progressView.progress = Float((CMTimeGetSeconds(time) / duration))
            if !self.activityIndicator.isHidden { self.activityIndicator.stopAnimating() }
            
            self.mPNowPlayingInfoCenter?.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackProgress] = currentTime
            self.mPNowPlayingInfoCenter?.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
            self.mPNowPlayingInfoCenter?.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = duration
        }
    }
    
    ///_____________________________
    private func updateAllPlayers(with podcast: Podcast?) {
        guard let podcast = podcast else { return }
        updateSmallPlayer(with: podcast)
        updateBigBlayer(with: podcast)
        updateMPRemoteCommandCenter(with: podcast)
    }
    
    private func updateBigBlayer(with podcast: Podcast?) {
        if let podcast = podcast, bigPlayerVC.isPresented {
            bigPlayerVC.upDateUI(with: podcast, isFirst: isFirstPodcast, isLast: isLastPodcast, playStopButton: playStopImage)
        }
    }
    
    private func updateSmallPlayer(with podcast: Podcast) {
        DataProvider.shared.downloadImage(string: podcast.artworkUrl600) { [weak self] image in
            self?.podcastImageView.image = image
        }
        podcastNameLabel.text = podcast.trackName
    }
    
    private func refreshAllPlayers() {
        bigPlayerVC.refreshInfo()
        refreshInfo()
    }
    
    private func refreshInfo() {
        podcastImageView.image = nil
        podcastNameLabel.text = "refreshing"
        progressView.progress = 1
    }
    
    private func removeTimeObserve() {
        if let observe = observe {
            player.removeTimeObserver(observe)
            self.observe = nil
        }
    }
    
    private func updateMPRemoteCommandCenter(with podcast: Podcast) {
        mpRemoteCommandCenter?.previousTrackCommand.isEnabled = !isFirstPodcast
        mpRemoteCommandCenter?.nextTrackCommand.isEnabled = !isLastPodcast
    }
    
    private func configureMPRemoteCommandCenter () {
        
        mpRemoteCommandCenter = MPRemoteCommandCenter.shared()
        
        mpRemoteCommandCenter?.nextTrackCommand.addTarget { [weak self] _ in
            self?.playNextPodcast()
            return .success
        }
        
        mpRemoteCommandCenter?.previousTrackCommand.addTarget { [weak self] _ in
            self?.playPreviewsPodcast()
            return .success
        }
       
        mpRemoteCommandCenter?.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.playOrPause()
            return .success
        }
    }
    
    private func addLikeMoment(moment: Double) {
        guard let podcast = currentPodcast?.podcast , let _ = currentPodcast?.podcast.id else { return }
        // TODO: - Alert
        LikedMoment.addLikeMoment(podcast: podcast, moment: moment)
    }
}

// MARK: - BigPlayerViewControllerDelegate
extension PlayerViewController: BigPlayerViewControllerDelegate {
    
    func bigPlayerViewController(_ bigPlayerViewController: BigPlayerViewController, didLikeThis moment: Double) {
        addLikeMoment(moment: moment)
        guard let trackName = currentPodcast?.podcast.trackName else { return }
        MyToast.create(title: trackName + "is added at " + moment.formattedString, .bottom, for: bigPlayerViewController.view)
    }
    
    func bigPlayerViewController(_ bigPlayerViewController: BigPlayerViewController, didChangeCurrentTime value: Double) {
        playerSeek(to: value)
    }
    
    func bigPlayerViewControllerDidSelectPlayStopButton(_ bigPlayerViewController: BigPlayerViewController) {
        playOrPause()
    }
    
    func bigPlayerViewControllerDidSelectNextTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        playNextPodcast()
    }
    
    func bigPlayerViewControllerDidSelectPreviewsTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        playPreviewsPodcast()
    }
    
    func bigPlayerViewController (_ bigPlayerViewController: BigPlayerViewController, didAddCurrentTimeBy value: Double) {
        guard let currentTime = player.currentItem?.currentTime().seconds else { return }
        playerSeek(to: currentTime + value)
    }
}
