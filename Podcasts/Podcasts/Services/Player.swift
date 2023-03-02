//
//  Player.swift
//  Podcasts
//
//  Created by Anton on 06.02.2023.
//

import Foundation
import MediaPlayer

protocol PlayerDelegate: AnyObject {
    func playerEndPlay(player: OutputPlayerProtocol)
    func playerStartLoading(player: OutputPlayerProtocol)
    func playerDidEndLoading(player: OutputPlayerProtocol)
    func playerUpdatePlayingInformation(player: OutputPlayerProtocol)
    func playerStateDidChanged(player: OutputPlayerProtocol)
}

protocol InputPlayerProtocol {
    var url: URL?                      { get }
    var image600: String?              { get }
    var image160: String?              { get }
    var image60: String?               { get }
    var trackName: String?             { get }
    var id: NSNumber?                  { get }
//    var isFavorite: Bool               { get }
    var descriptionMy: String?         { get }
    var genresString: String?          { get }
    var releaseDate: String?           { get }
    var trackTimeMillisString: String? { get }
    var trackTimeMillis: NSNumber?     { get }
    var contentAdvisoryRating: String? { get }
    var artistName: String?            { get }
    var country: String?               { get }
    
    var currentTime: Float?            { get set }
    var progress: Double?              { get set }
    var duration: Double?              { get set }
}

protocol OutputPlayerProtocol: DetailPlayableProtocol, SmallPlayerPlayableProtocol, BigPlayerPlayableProtocol {
    
}

class Player {
    
    var playlist: [InputPlayerProtocol] = []
    var currentTrack: (track: InputPlayerProtocol, index: Int)?
    
    private var mpRemoteCommandCenter: MPRemoteCommandCenter?
    private var mPNowPlayingInfoCenter: MPNowPlayingInfoCenter?
    
    private(set) var playerAVP: AVPlayer = AVPlayer()
    
    private var observe: Any?
    
    weak var delegate: PlayerDelegate?
    weak var smallPlayerDelegate: PlayerDelegate?
    
    private(set) var isPlaying = false {
        didSet {
            if oldValue != isPlaying {
                delegate?.playerStateDidChanged(player: self)
            }
        }
    }
    
    
    var isLast: Bool { (currentTrack?.index ?? (Int.max - 1)) + 1 == playlist.count }
    var isFirst: Bool { currentTrack?.index ?? 1 == 0 }
    
    private(set) var playerIsLoading: Bool = false {
        didSet {
            if playerIsLoading != oldValue {
                if playerIsLoading {
                    delegate?.playerStartLoading(player: self)
                } else {
                    delegate?.playerDidEndLoading(player: self)
                }
            }
        }
    }
    
    init() {
        addObserverForEndTrack()
        configureMPRemoteCommandCenter ()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        mpRemoteCommandCenter = nil
    }
    
    //MARK: - public Methods
    func pause() {
        playerAVP.pause()
        removeTimeObserve()
        isPlaying = false
    }
    
    func play() {
        playerAVP.play()
        isPlaying = true
        addTimeObserve()
    }
    
    func playOrPause() {
        playerAVP.rate == 1 ? pause() : play()
    }

    func playerSeek(to seconds: Double) {
        self.playerAVP.seek(to: CMTime(seconds: seconds, preferredTimescale: 60))
    }
    
    func playerRewindSeek(to seconds: Double) {
        let currentTime = playerAVP.currentTime().seconds
        playerSeek(to: currentTime + seconds)
    }
    
    func startPlay(track: InputPlayerProtocol, playList: [InputPlayerProtocol], at moment: Double? = nil) {
        guard track.id != currentTrack?.track.id else { playOrPause(); return }
        self.playlist = playList
        if let index = playList.firstIndex(where: { track.id == $0.id }) {
            changeTrack(with: track)
            self.currentTrack = (track: track, index: index)
            startPlay(track: track, at: moment)
        }
    }
    
    func playPreviewsTrack() {
        guard !playlist.isEmpty, let currentItem = currentTrack, !isFirst else { return }
        let index = currentItem.index - 1
        let track = playlist[index]
        changeTrack(with: track)
        self.currentTrack = (track: track, index: index)
        startPlay(track: track)
    }
    
    //MARK: Actions
    @objc func playNextPodcast() {
        guard !playlist.isEmpty, let currentItem = currentTrack, !isLast else { playOrPause(); return }
        let index = currentItem.index + 1
        let track = playlist[index]
        changeTrack(with: track)
        self.currentTrack = (track: track, index: index)
        startPlay(track: track)
    }
}

// MARK: - Private Methods
extension Player: OutputPlayerProtocol {
    
    private func startPlay(track: InputPlayerProtocol, at moment: Double? = nil) {
        pause()
        playerAVP.replaceCurrentItem(with: nil)
        self.playerIsLoading = true
        //        let requestWorkItem = DispatchWorkItem { [weak self] in
        //            guard let self = self else { return }
        
        guard let url = track.url else { return }
        let item = AVPlayerItem(url: url.isDownLoad ? url.localPath : url)
        self.playerAVP.replaceCurrentItem(with: item)
        if let moment = moment { self.playerSeek(to: moment) }
        play()
        
        //            DispatchQueue.main.async {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate  {
            sceneDelegate.videoViewController = self
        }
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
        observe = playerAVP.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: Int32(NSEC_PER_SEC)), queue: .main ) { [weak self] time in
            guard let self = self,
                  let duration = self.playerAVP.currentItem?.duration.seconds,
                  !duration.isNaN
            else { return }
            
            let currentTime = Float(self.playerAVP.currentTime().seconds)
            let progress = CMTimeGetSeconds(time) / duration
            
            self.playerIsLoading = false
            
            self.currentTrack?.track.currentTime = currentTime
            self.currentTrack?.track.progress = progress
            self.currentTrack?.track.duration = duration
            
            self.delegate?.playerUpdatePlayingInformation(player: self)
            
            /// ---------------
            self.mPNowPlayingInfoCenter?.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackProgress] = currentTime
            self.mPNowPlayingInfoCenter?.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
            self.mPNowPlayingInfoCenter?.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = duration
        }
    }
    
    private func removeTimeObserve() {
        if let observe = observe {
            playerAVP.removeTimeObserver(observe)
            self.observe = nil
        }
    }
    
    private func updateMPRemoteCommandCenter(with podcast: Podcast) {
        mpRemoteCommandCenter?.previousTrackCommand.isEnabled = !isFirst
        mpRemoteCommandCenter?.nextTrackCommand.isEnabled = !isLast
    }
    
    private func changeTrack(with newTrack: InputPlayerProtocol) {
        if let track = currentTrack?.track, newTrack.id != track.id {
            delegate?.playerEndPlay(player: self)
        }
    }
    
    private func configureMPRemoteCommandCenter () {
        
        mpRemoteCommandCenter = MPRemoteCommandCenter.shared()
        
        mpRemoteCommandCenter?.nextTrackCommand.addTarget { [weak self] _ in
            self?.playNextPodcast()
            return .success
        }
        
        mpRemoteCommandCenter?.previousTrackCommand.addTarget { [weak self] _ in
            self?.playPreviewsTrack()
            return .success
        }
        
        mpRemoteCommandCenter?.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.playOrPause()
            return .success
        }
    }
    
    private func addObserverForEndTrack() {
        NotificationCenter.default.addObserver(self, selector: #selector(playNextPodcast), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}




extension Player {
    var id: NSNumber? { currentTrack?.track.id }
    var track: InputPlayerProtocol? { currentTrack?.track }
    var progress: Double? { currentTrack?.track.progress }
    var trackImage: String? { currentTrack?.track.image60 }
    var trackName: String? { currentTrack?.track.trackName }
    var currentTime: Float? { currentTrack?.track.currentTime }
    var duration: Double? { currentTrack?.track.duration }
}

