//
//  Player.swift
//  Podcasts
//
//  Created by Anton on 06.02.2023.
//

import Foundation
import MediaPlayer
import CoreData

protocol InputPlayer: MultyDelegateServiceInput {
    
    var currentTrack: (track: Track, index: Int)? { get }
    
    var isPlaying: Bool { get }
    
    func pause()
    func play()
    
    func playOrPause()
    func playPreviewsTrack()
    func playNextPodcast()
    func update(with listening: ListeningPodcast)
    
    func playerSeek(to seconds: Double)
    
    func playerRewindSeek(to seconds: Double)
    func conform(track: any TrackProtocol, trackList: [any TrackProtocol])
}

protocol TrackProtocol: NSManagedObject {
    var url: URL?                      { get }
    var imageForMpPlayer: String?      { get }
    var imageForBigPlayer: String?     { get }
    var imageForSmallPlayer: String?   { get }
    var trackName: String?             { get }
    var descriptionMy: String?         { get }
    var trackId: String                { get }
    var listeningProgress: Double?     { get }
    var currentTime: Float?            { get }
    var duration: Double?              { get }
}

struct Track: Equatable, OutputPlayerProtocol {
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.trackId == rhs.trackId
    }
    
    var inputType: TrackProtocol
    
    var imageForBigPlayer: String?
    var imageForSmallPlayer: String?
    
    var duration: Double?
    var trackImageForBigPlayer: String?
    var currentTime: Float?
    var listeningProgress: Double?
    var isPlaying: Bool = false
    var isGoingPlaying: Bool = false
    var trackId: String
    var imageForMpPlayer: String?
    var trackName: String?
    var url: URL?
    var isLast: Bool
    var isFirst: Bool = false
  
    
    init(input: any TrackProtocol, isLast: Bool, isFirst: Bool) {
        self.currentTime = input.currentTime
        self.listeningProgress = input.listeningProgress
        self.trackId = input.trackId
        self.imageForMpPlayer = input.imageForMpPlayer
        self.trackName = input.trackName
        self.url = input.url
        self.inputType = input
        self.isLast = isLast
        self.isFirst = isFirst
        self.imageForSmallPlayer = input.imageForSmallPlayer
        self.imageForBigPlayer = input.imageForBigPlayer
        self.duration = input.duration
    }
}

protocol OutputPlayerProtocol: PodcastCellPlayableProtocol, BigPlayerPlayableProtocol, SmallPlayerPlayableProtocol {}

protocol PlayerDelegate {
    
    func playerDidEndPlay               (with track: OutputPlayerProtocol)
    func playerStartLoading             (with track: OutputPlayerProtocol)
    func playerDidEndLoading            (with track: OutputPlayerProtocol)
    func playerUpdatePlayingInformation (with track: OutputPlayerProtocol)
    func playerStateDidChanged          (with track: OutputPlayerProtocol)
}

class Player: MultyDelegateService<PlayerDelegate> {
    
    //MARK: init
    override init() {
        super.init()
        addObserverForEndTrack()
        configureMPRemoteCommandCenter()
    }
   
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
    
    private(set) var isLoading: Bool = false {
        didSet {
            if oldValue != isLoading {
                currentTrack?.track.isGoingPlaying = isLoading
                if isLoading {
                    playerStartLoading(track: currentTrack?.track)
                } else {
                    playerDidEndLoading(track: currentTrack?.track)
                }
            }
        }
    }
}

extension Player: InputPlayer {
   
    //MARK: - public Methods
    //MARK: Actions
    
    func conform(track: any TrackProtocol, trackList: [any TrackProtocol]) {
        if currentTrack?.track.trackId == track.trackId {
            playOrPause()
        } else {
            startPlay(track: track, tracks: trackList)
        }
    }
    
    func pause() {
        playerAVP.pause()
        removeTimeObserve()
        isPlaying = false
        isLoading = false
    }
    
    func play() {
        playerAVP.play()
        addTimeObserve()
        isPlaying = true
    }
    
    func playOrPause() {
        playerAVP.rate == 1 ? pause() : play()
    }
    
    func playerSeek(to seconds: Double) {
        isLoading = true
        playerAVP.seek(to: CMTime(seconds: seconds, preferredTimescale: 60))
        play()
    }
    
    func playerRewindSeek(to seconds: Double) {
        isLoading = true
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
        guard let url = track.url else { return }

        if currentTrack != nil {
            pause()
        }
        
        currentTrack = (track: track, index: indexInPlaylist)
        isLoading = true
       
        ///------------------
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
        ///------------------
        
        let item = AVPlayerItem(url: url.isDownLoad ? url.localPath : url)
        self.playerAVP.replaceCurrentItem(with: item)
        
        if let currentTime = track.currentTime, let duration = track.duration, currentTime != Float(duration) {
            self.playerAVP.seek(to: CMTime(seconds: Double(currentTime), preferredTimescale: 60))
        }
       
        play()
    }
    
    private func addTimeObserve() {
        
        guard observe == nil else { fatalError() }
        
        observe = playerAVP.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: Int32(NSEC_PER_SEC)), queue: .main ) { [weak self] time in
            guard let self = self,
                  let duration = playerAVP.currentItem?.duration.seconds,
                  !duration.isNaN
            else { return }
            
            let currentTime = Float(self.playerAVP.currentTime().seconds)
            let progress = CMTimeGetSeconds(time) / duration
            
            isLoading = false
            
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
        delegates {
            $0.playerDidEndPlay(with: track)
        }
    }
    
    private func playerStartLoading(track: Track?) {
        guard let track = track else { return }
        delegates {
            $0.playerStartLoading(with: track)
        }
    }
    
    private func playerDidEndLoading(track: Track?) {
        guard let track = track else { return }
        delegates {
            $0.playerDidEndLoading(with: track)
        }
    }
    
    private func playerUpdatePlayingInformation(track: Track?) {
        guard let track = track else { return }
        delegates {
            $0.playerUpdatePlayingInformation(with: track)
        }
    }
    
    private func playerStateDidChanged(track: Track?) {
        guard let track = track else { return }
        delegates {
            $0.playerStateDidChanged(with: track)
        }
    }
    
    func update(with listening: ListeningPodcast) {
        guard currentTrack?.track.trackId != listening.podcast.trackId else { return }
       
        var track = Track(input: listening.podcast, isLast: false, isFirst: false)
        track.listeningProgress = listening.progress
        track.currentTime = listening.currentTime
        track.duration = listening.duration
        
        delegates {
            $0.playerUpdatePlayingInformation(with: track)
        }
    }
    
    private func startPlay(track: (any TrackProtocol), tracks: [any TrackProtocol]) {
        
        guard track.trackId != currentTrack?.track.trackId else { playOrPause(); return }
        
        let isLast = tracks.firstIndex { $0.trackId == track.trackId } ?? Int.max - 1 == tracks.count - 1
        let isFirst = tracks.firstIndex { $0.trackId == track.trackId } ?? 1 == 0
        
        self.playlist = tracks.map { Track(input: $0, isLast: isLast, isFirst: isFirst) }
        let track: Track = Track(input: track, isLast: isLast, isFirst: isFirst)
        
        if let index = tracks.firstIndex(where: { track.trackId == $0.trackId }) {
            startPlay(track: track, indexInPlaylist: index)
        }
    }
}


