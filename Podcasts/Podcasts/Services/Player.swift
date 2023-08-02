//
//  Player.swift
//  Podcasts
//
//  Created by Anton on 06.02.2023.
//

import Foundation
import MediaPlayer
import CoreData

protocol InputPlayer {
    
    var currentTrack: (track: Track, index: Int)? { get }

    
    func playOrPause()
    func playPreviewsTrack()
    func playNextPodcast()
    
    func playerSeek(to seconds: Double)
    
    func playerRewindSeek(to seconds: Double)
    func conform(entity: any InputTrackType, entities: [any InputTrackType])
    func addObserverPlayerEventNotification <T: PlayerEventNotification>(for object: T)
}

protocol InputTrackType {
    var track: TrackProtocol { get }
}

protocol TrackProtocol: NSManagedObject {
    var url: URL?                      { get }
    var imageForMpPlayer: String?      { get }
    var imageForBigPlayer: String?     { get }
    var imageForSmallPlayer: String?   { get }
    var trackName: String?             { get }
    var descriptionMy: String?         { get }
    var trackIdentifier: String        { get }
    var listeningProgress: Double?     { get }
    var currentTime: Float?            { get }
}

struct Track: OutputPlayerProtocol {
    
    var inputType: TrackProtocol
    
    var imageForBigPlayer: String?
    var imageForSmallPlayer: String?
    
    var duration: Double = 0
    var trackImageForBigPlayer: String?
    var currentTime: Float?
    var listeningProgress: Double = 0
    var isPlaying: Bool = false
    var isGoingPlaying: Bool = false
    var trackIdentifier: String
    var imageForMpPlayer: String?
    var trackName: String?
    var url: URL?
    var isLast: Bool
    var isFirst: Bool = false
    
    init(input: any TrackProtocol, isLast: Bool, isFirst: Bool) {
        self.currentTime = input.currentTime
        self.listeningProgress = input.listeningProgress ?? 0
        self.trackIdentifier = input.trackIdentifier
        self.imageForMpPlayer = input.imageForMpPlayer
        self.trackName = input.trackName
        self.url = input.url
        self.inputType = input
        self.isLast = isLast
        self.isFirst = isFirst
        self.imageForSmallPlayer = input.imageForSmallPlayer
        self.imageForBigPlayer = input.imageForBigPlayer
    }
}

protocol OutputPlayerProtocol: PodcastCellPlayableProtocol, BigPlayerPlayableProtocol, SmallPlayerPlayableProtocol {}

protocol PlayerEventNotification: AnyObject {

    func playerDidEndPlay               (with track: OutputPlayerProtocol)
    func playerStartLoading             (with track: OutputPlayerProtocol)
    func playerDidEndLoading            (with track: OutputPlayerProtocol)
    func playerUpdatePlayingInformation (with track: OutputPlayerProtocol)
    func playerStateDidChanged          (with track: OutputPlayerProtocol)
}

class Player {
    
    //MARK: init
    init() {
        addObserverForEndTrack()
        configureMPRemoteCommandCenter()
    }
    
    class WeakObject {
        weak var weakObject: (any PlayerEventNotification)?
        init(object: any PlayerEventNotification) {
            self.weakObject = object
        }
    }
    private(set) var delegates: [WeakObject] = []
    
    private(set) var playlist: [Track] = []
    private(set) var currentTrack: (track: Track, index: Int)?
    private var mpRemoteCommandCenter = MPRemoteCommandCenter.shared()
    private var mPNowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    
    private(set) var playerAVP: AVPlayer = AVPlayer()
    
    private var observe: Any?
    
    private(set) var isPlaying = false {
        didSet {
            if oldValue != isPlaying {
                currentTrack?.track.isPlaying = isPlaying
                playerStateDidChanged(track: currentTrack?.track)
            }
        }
    }
    
    private var isLast: Bool { (currentTrack?.index ?? (Int.max - 1)) + 1 == playlist.count }
    private var isFirst: Bool { currentTrack?.index ?? 1 == 0 }
    
    private(set) var playerIsLoadingNewTrack: Bool = false {
        didSet {
            if oldValue != playerIsLoadingNewTrack {
                currentTrack?.track.isGoingPlaying = playerIsLoadingNewTrack
                if playerIsLoadingNewTrack {
                    playerStartLoading(track: currentTrack?.track)
                } else {
                    playerDidEndLoading(track: currentTrack?.track)
                }
            }
        }
    }
}

extension Player: InputPlayer {
    
    func addObserverPlayerEventNotification <T: PlayerEventNotification>(for object: T) {
        let weakObject = WeakObject(object: object)
        delegates.append(weakObject)
    }
    
    //MARK: - public Methods
    //MARK: Actions
    
    func conform(entity: any InputTrackType, entities: [any InputTrackType]) {
        let track = entity.track
        if currentTrack?.track.trackIdentifier == track.trackIdentifier {
            playOrPause()
        } else {
            startPlay(track: track, tracks: entities.map { $0.track })
        }
    }
    
    func playOrPause() {
        playerAVP.rate == 1 ? pause() : play()
    }
    
    func playerSeek(to seconds: Double) {
        playerAVP.pause()
        self.playerAVP.seek(to: CMTime(seconds: seconds, preferredTimescale: 60))
        playerAVP.play()
        isPlaying = true
    }
    
    func playerRewindSeek(to seconds: Double) {
        let currentTime = playerAVP.currentTime().seconds
        playerSeek(to: currentTime + seconds)
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
    
    private func startPlay(track: Track, indexInPlaylist: Int) {
        pause()
       
        playerDidEndPlay(track: currentTrack?.track)
        currentTrack = (track: track, index: indexInPlaylist)
        
        playerAVP.replaceCurrentItem(with: nil)
        
        mpRemoteCommandCenter.previousTrackCommand.isEnabled = !isFirst
        mpRemoteCommandCenter.nextTrackCommand.isEnabled = !isLast
        
        if let image = track.imageForMpPlayer?.getImage {
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
        self.playerSeek(to: 1)
        
        play()
        
        if let _ = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate  {
            //TODO: - 
//            sceneDelegate.videoViewController = self
        }
    }
    
    private func addTimeObserve() {
        observe = playerAVP.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(2, preferredTimescale: Int32(NSEC_PER_SEC)), queue: .main ) { [weak self] time in
            guard let self = self,
                  let duration = playerAVP.currentItem?.duration.seconds,
                  !duration.isNaN
            else { return }
            
            let currentTime = Float(self.playerAVP.currentTime().seconds)
            let progress = CMTimeGetSeconds(time) / duration
            
            playerIsLoadingNewTrack = false
            
            currentTrack?.track.currentTime = currentTime
            currentTrack?.track.listeningProgress = progress
            currentTrack?.track.duration = duration
            
            playerUpdatePlayingInformation(track: currentTrack?.track)
            /// ---------------
            mPNowPlayingInfoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackProgress] = currentTime
            mPNowPlayingInfoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
            mPNowPlayingInfoCenter.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = duration
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
    
    private func playerDidEndPlay(track: Track?) {
        guard let track = track else { return }
        delegates.forEach {
            $0.weakObject?.playerDidEndPlay(with: track)
        }
    }
    
    private func playerStartLoading(track: Track?) {
        guard let track = track else { return }
        delegates.forEach {
            $0.weakObject?.playerStartLoading(with: track)
        }
    }
    
    private func playerDidEndLoading(track: Track?) {
        guard let track = track else { return }
        delegates.forEach {
            $0.weakObject?.playerDidEndLoading(with: track)
        }
    }
    
    private func playerUpdatePlayingInformation(track: Track?) {
        guard let track = track else { return }
        delegates.forEach {
            $0.weakObject?.playerUpdatePlayingInformation(with: track)
        }
    }
    
    private func playerStateDidChanged(track: Track?) {
        guard let track = track else { return }
        delegates.forEach {
            $0.weakObject?.playerStateDidChanged(with: track)
        }
    }
    
    private func pause() {
        playerIsLoadingNewTrack = false
        playerAVP.pause()
        removeTimeObserve()
        isPlaying = false
    }
    
    private func play() {
        playerIsLoadingNewTrack = true
        addTimeObserve()
        playerAVP.play()
        isPlaying = true
    }
    
    private func startPlay(track: (any TrackProtocol), tracks: [any TrackProtocol]) {
        guard track.trackIdentifier != currentTrack?.track.trackIdentifier else { playOrPause(); return }

        let isLast = tracks.firstIndex { $0.trackIdentifier == track.trackIdentifier } ?? Int.max - 1 == tracks.count - 1
        let isFirst = tracks.firstIndex { $0.trackIdentifier == track.trackIdentifier } ?? 1 == 0
        
        self.playlist = tracks.map { Track(input: $0, isLast: isLast, isFirst: isFirst) }
        let track = Track(input: track, isLast: isLast, isFirst: isFirst)
        
        if let index = tracks.firstIndex(where: { track.trackIdentifier == $0.trackIdentifier }) {
            startPlay(track: track, indexInPlaylist: index)
        }
    }
}
