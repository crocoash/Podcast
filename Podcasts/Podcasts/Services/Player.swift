//
//  Player.swift
//  Podcasts
//
//  Created by Anton on 06.02.2023.
//

import Foundation
import MediaPlayer

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

@objc protocol PlayerEventNotification {
    func addObserverPlayerEventNotification()
    func removeObserverEventNotification()
    func playerDidEndPlay(notification: NSNotification)
    func playerStartLoading(notification: NSNotification)
    func playerDidEndLoading(notification: NSNotification)
    func playerUpdatePlayingInformation(notification: NSNotification)
    func playerStateDidChanged(notification: NSNotification)
}

//MARK: - OutputPlayerProtocol
protocol OutputPlayerProtocol:  SmallPlayerPlayableProtocol, BigPlayerPlayableProtocol {
    
}

extension Player: OutputPlayerProtocol {
    var id: NSNumber? { currentTrack?.track.id }
    var track: InputPlayerProtocol? { currentTrack?.track }
    var progress: Double? { currentTrack?.track.progress }
    var trackImage: String? { currentTrack?.track.image600 }
    var trackName: String? { currentTrack?.track.trackName }
    var currentTime: Float? { currentTrack?.track.currentTime }
    var duration: Double? { currentTrack?.track.duration }
}

class Player {
    
    private enum PlayerEvent: String {
        case playerEndPlay
        case playerStartLoading
        case playerDidEndLoading
        case playerUpdatePlayingInformation
        case playerStateDidChanged
        
        var notificationName: NSNotification.Name {
            return NSNotification.Name(rawValue: self.rawValue)
        }
    }
    
    static func addObserverPlayerPlayerEventNotification <T: PlayerEventNotification>(for object: T) {
        let playerEndPlay = PlayerEvent.playerEndPlay.notificationName
        NotificationCenter.default.addObserver(object, selector: #selector(object.playerDidEndPlay(notification: )), name: playerEndPlay, object: nil)
        
        let playerStartLoading = PlayerEvent.playerStartLoading.notificationName
        NotificationCenter.default.addObserver(object, selector: #selector(object.playerStartLoading(notification: )), name: playerStartLoading, object: nil)
        
        let playerDidEndLoading = PlayerEvent.playerDidEndLoading.notificationName
        NotificationCenter.default.addObserver(object, selector: #selector(object.playerDidEndLoading(notification: )), name: playerDidEndLoading, object: nil)
        
        let playerUpdatePlayingInformation = PlayerEvent.playerUpdatePlayingInformation.notificationName
        NotificationCenter.default.addObserver(object, selector: #selector(object.playerUpdatePlayingInformation(notification: )), name: playerUpdatePlayingInformation, object: nil)
        
        let playerStateDidChanged = PlayerEvent.playerStateDidChanged.notificationName
        NotificationCenter.default.addObserver(object, selector: #selector(object.playerStateDidChanged(notification: )), name: playerStateDidChanged, object: nil)
    }
    
    static func removeObserverEventNotification<T: PlayerEventNotification>(for object: T) {
        NotificationCenter.default.removeObserver(object)
    }
    
    var playlist: [InputPlayerProtocol] = []
    var currentTrack: (track: InputPlayerProtocol, index: Int)?
    private var mpRemoteCommandCenter = MPRemoteCommandCenter.shared()
    private var mPNowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    
    private(set) var playerAVP: AVPlayer = AVPlayer()
    
    private var observe: Any?
    
    private(set) var isPlaying = false {
        didSet {
            if oldValue != isPlaying {
                NotificationCenter.default.post(name: PlayerEvent.playerStateDidChanged.notificationName, object: self)
            }
        }
    }
    
    var isLast: Bool { (currentTrack?.index ?? (Int.max - 1)) + 1 == playlist.count }
    var isFirst: Bool { currentTrack?.index ?? 1 == 0 }
    
    private(set) var playerIsLoadingNewTrack: Bool = false {
        didSet {
            if playerIsLoadingNewTrack != oldValue {
                if playerIsLoadingNewTrack {
                    NotificationCenter.default.post(name: PlayerEvent.playerStartLoading.notificationName, object: self)
                } else {
                    NotificationCenter.default.post(name: PlayerEvent.playerDidEndLoading.notificationName, object: self)
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
        playerAVP.pause()
        isPlaying = false
        self.playerAVP.seek(to: CMTime(seconds: seconds, preferredTimescale: 60))
        playerAVP.play()
        isPlaying = true
    }
    
    func playerRewindSeek(to seconds: Double) {
        let currentTime = playerAVP.currentTime().seconds
        playerSeek(to: currentTime + seconds)
    }
    
    func startPlay(track: InputPlayerProtocol, playList: [InputPlayerProtocol], at moment: Double? = nil) {
        guard track.id != currentTrack?.track.id else { playOrPause(); return }
        self.playlist = playList
        if let index = playList.firstIndex(where: { track.id == $0.id }) {
            startPlay(track: track, indexInPlaylist: index, at: moment)
        }
    }
    
    func playPreviewsTrack() {
        guard !playlist.isEmpty, let currentItem = currentTrack, !isFirst else { return }
        let index = currentItem.index - 1
        let track = playlist[index]
        startPlay(track: track, indexInPlaylist: index)
    }
    
    @objc func playNextPodcast() {
        guard !playlist.isEmpty, let currentItem = currentTrack, !isLast else { playOrPause(); return }
        let index = currentItem.index + 1
        let track = playlist[index]
        startPlay(track: track, indexInPlaylist: index)
    }
}

// MARK: - Private Methods
extension Player {
    
    private func startPlay(track: InputPlayerProtocol, indexInPlaylist: Int, at moment: Double? = nil) {
        pause()
        NotificationCenter.default.post(name: PlayerEvent.playerEndPlay.notificationName, object: self)
        currentTrack = (track: track, index: indexInPlaylist)
        
        playerIsLoadingNewTrack = true
        playerAVP.replaceCurrentItem(with: nil)
        
        mpRemoteCommandCenter.previousTrackCommand.isEnabled = !isFirst
        mpRemoteCommandCenter.nextTrackCommand.isEnabled = !isLast
        
        if let image = trackImage?.getImage {
            let size = CGSize(width: image.size.width, height: image.size.height)
            let item = MPMediaItemArtwork(boundsSize: size) { _ in
                return image
            }
            mPNowPlayingInfoCenter.nowPlayingInfo = [
                MPMediaItemPropertyTitle: track.trackName ?? "No track name",
                MPMediaItemPropertyArtwork: item
            ]
        }
        
        guard let url = track.url else { return }
        let item = AVPlayerItem(url: url.isDownLoad ? url.localPath : url)
        self.playerAVP.replaceCurrentItem(with: item)
        if let moment = moment { self.playerSeek(to: moment) }
        
        play()
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate  {
            sceneDelegate.videoViewController = self
        }
    }
    
    private func addTimeObserve() {
        observe = playerAVP.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: Int32(NSEC_PER_SEC)), queue: .main ) { [weak self] time in
            guard let self = self,
                  let duration = self.playerAVP.currentItem?.duration.seconds,
                  !duration.isNaN
            else { return }
            
            let currentTime = Float(self.playerAVP.currentTime().seconds)
            let progress = CMTimeGetSeconds(time) / duration
            
            self.playerIsLoadingNewTrack = false
            
            self.currentTrack?.track.currentTime = currentTime
            self.currentTrack?.track.progress = progress
            self.currentTrack?.track.duration = duration
            
            NotificationCenter.default.post(name: PlayerEvent.playerUpdatePlayingInformation.notificationName, object: self)
            
            /// ---------------
            self.mPNowPlayingInfoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackProgress] = currentTime
            self.mPNowPlayingInfoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
            self.mPNowPlayingInfoCenter.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = duration
        }
    }
    
    private func removeTimeObserve() {
        if let observe = observe {
            playerAVP.removeTimeObserver(observe)
            self.observe = nil
        }
    }
    
    private func configureMPRemoteCommandCenter () {
    
        mpRemoteCommandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.playNextPodcast()
            return .success
        }
        
        mpRemoteCommandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.playPreviewsTrack()
            return .success
        }
        
        mpRemoteCommandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.playOrPause()
            return .success
        }
        
        mpRemoteCommandCenter.seekForwardCommand.addTarget { [weak self] event in
            self?.playerRewindSeek(to: 60)
            return .success
        }
        
        mpRemoteCommandCenter.seekBackwardCommand.addTarget { [weak self] event in
            self?.playerRewindSeek(to: -60)
            return .success
        }
        
    }
    
    private func addObserverForEndTrack() {
        NotificationCenter.default.addObserver(self, selector: #selector(playNextPodcast), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}
