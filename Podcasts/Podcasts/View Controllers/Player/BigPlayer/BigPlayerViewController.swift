//
//  BigPlayerViewController.swift
//  Podcasts
//
//  Created by mac on 01.11.2021.
//

import UIKit
import AVFoundation
import CoreData

protocol BigPlayerViewControllerDelegate: AnyObject {
    func bigPlayerViewControllerDidTouchPodcastNameLabel(_ bigPlayerViewController: BigPlayerViewController, entity: NSManagedObject)
}

protocol BigPlayerPlayableProtocol {
    
    var isGoingPlaying: Bool { get }
    var isLast: Bool { get }
    var isFirst: Bool { get }
    var isPlaying: Bool { get }
    var trackName: String? { get }
    var imageForBigPlayer: String? { get }
    var currentTime: Float? { get }
    var duration: Double { get }
    var inputType: TrackProtocol { get }
}

struct BigPlayerModel: BigPlayerPlayableProtocol {
    
    var inputType: TrackProtocol
    
    var isGoingPlaying: Bool
    var isLast: Bool
    var isFirst: Bool
    var isPlaying: Bool
    var trackName: String?
    var imageForBigPlayer: String?
    var currentTime: Float?
    var duration: Double
    
    init(model: BigPlayerPlayableProtocol) {
        self.isGoingPlaying = model.isGoingPlaying
        self.isLast = model.isLast
        self.isFirst = model.isFirst
        self.isPlaying = model.isPlaying
        self.trackName = model.trackName
        self.imageForBigPlayer = model.imageForBigPlayer
        self.currentTime = model.currentTime
        self.duration = model.duration
        self.inputType = model.inputType
    }
    
    mutating func update(_ input: Any) {
        if let player = input as? BigPlayerPlayableProtocol {
            self.isGoingPlaying = player.isGoingPlaying
            self.isLast = player.isLast
            self.isFirst = player.isFirst
            self.isPlaying = player.isPlaying
            self.trackName = player.trackName
            self.imageForBigPlayer = player.imageForBigPlayer
            self.currentTime = player.currentTime
            self.duration = player.duration
            self.inputType = player.inputType
        }
    }
}

class BigPlayerViewController: UIViewController {
    
    @IBOutlet private weak var podcastImageView:      UIImageView!
    
    @IBOutlet private weak var podcastNameLabel:      UILabel!
    @IBOutlet private weak var currentTimeLabel:      UILabel!
    @IBOutlet private weak var durationTrackLabel:    UILabel!
    
    @IBOutlet private weak var progressSlider:        UISlider!
    
    @IBOutlet private weak var previousPodcastButton: UIButton!
    @IBOutlet private weak var nextPodcastButton:     UIButton!
    @IBOutlet private weak var playPauseButton:       UIButton!
    @IBOutlet private weak var likedButton:           UIButton!
    
    @IBOutlet private weak var activityIndicator:     UIActivityIndicatorView!
    
    weak var delegate: BigPlayerViewControllerDelegate?
    
    private(set) var model: BigPlayerModel {
        didSet {
            configure()
        }
    }
    
    private var player: Player
    private var addToLikeManager: AddToLikeManager
    
    private let defaultTime = "0:00"
    private var pauseImage = UIImage(systemName: "pause.fill")!
    private var playImage = UIImage(systemName: "play.fill")!
    private var bigPlayerPlayableProtocol: BigPlayerPlayableProtocol!
    
    //MARK: init
    init<T: BigPlayerViewControllerDelegate>(_ vc: T, player: Player, track: BigPlayerPlayableProtocol, addToLikeManager: AddToLikeManager) {
        self.player = player
        self.model = BigPlayerModel(model: track)
        self.delegate = vc
        self.addToLikeManager = addToLikeManager
        
        super.init(nibName: Self.identifier, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - PublicMethods
    
    private func configure() {
        progressSlider.maximumValue = Float(model.duration)
        progressSlider.value = model.currentTime ?? 0
        
        currentTimeLabel  .text = model.currentTime?.formatted
        durationTrackLabel.text = model.duration.formatted
        podcastNameLabel  .text = model.trackName
        
        activityIndicator.isHidden = !model.isGoingPlaying
        
        DataProvider.shared.downloadImage(string: model.imageForBigPlayer) { [weak self] image in
            self?.podcastImageView.image = image
        }
        
        likedButton          .isEnabled = !model.isGoingPlaying
        previousPodcastButton.isEnabled = !model.isFirst
        nextPodcastButton    .isEnabled = !model.isLast
        
        playPauseButton.setImage(model.isPlaying ? pauseImage : playImage, for: .normal)
    }
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserverPlayerEventNotification()
        configureGestures()
        configure()
    }
    
    //MARK:  Actions
    @objc func dismissBigPlayer() {
        dismiss(animated: true)
    }
    
    @objc func tapPodcastNameLabel(sender: UITapGestureRecognizer) {
        delegate?.bigPlayerViewControllerDidTouchPodcastNameLabel(self, entity: model.inputType )
    }
    
    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
        player.playerSeek(to: Double(sender.value))
    }
    
    @IBAction func playPauseTouchUpInside(_ sender: UIButton) {
        player.playOrPause()
    }
    
    @IBAction func nextPodcastTouchUpInside(_ sender: UIButton) {
        player.playNextPodcast()
    }
    
    @IBAction func previousPodcastTouchUpInside(_ sender: UIButton) {
        player.playPreviewsTrack()
    }
    
    @IBAction func tenSecondBackTouchUpInside(_ sender: UIButton) {
        player.playerSeek(to: -60)
    }
    
    @IBAction func tenSecondForwardTouchUpInside(_ sender: UIButton) {
        player.playerRewindSeek(to: 60)
    }
    
    @objc func respondToSwipe(gesture: Any) {
        dismissBigPlayer()
    }
    
    @IBAction func likedButton(_ sender: UIButton) {
        let moment = Double(progressSlider.value)
        addToLikeManager.addToLikedMoments(entity: model.inputType, moment: moment)
    }
    
    @IBAction func dissmisButtonTouchUpInside(_ sender: UIButton) {
        dismissBigPlayer()
    }
}

//MARK: - PrivateMethods
extension BigPlayerViewController {
    
    private func configureGestures() {
        addMyGestureRecognizer(self, type: .swipe(directions: [.down]), #selector(dismissBigPlayer))
        podcastNameLabel.addMyGestureRecognizer(self, type: .tap(), #selector(tapPodcastNameLabel))
    }
    
//    private func updateProgressSlider(player: BigPlayerPlayableProtocol) {
//        progressSlider.value = player.currentTime ?? 0
//        progressSlider.maximumValue = Float(player.playingDuration ?? 0)
//        currentTimeLabel.text = player.currentTime?.formatted ?? defaultTime
//        durationTrackLabel.text = player.playingDuration?.formatted ?? defaultTime
//        if !likedButton.isEnabled { likedButton.isEnabled = true }
//    }
//
//    private func playerEndPlay(player: BigPlayerPlayableProtocol) {
//        progressSlider.value = 0
//        progressSlider.maximumValue = 0
//        currentTimeLabel.text = defaultTime
//        durationTrackLabel.text = defaultTime
//        likedButton.isEnabled = false
//    }
}
 
//MARK: - PlayerEventNotification
extension BigPlayerViewController: PlayerEventNotification {
    
    func playerDidEndPlay(with track: OutputPlayerProtocol) {
        model.update(track)
    }
    
    func playerStartLoading(with track: OutputPlayerProtocol) {
        model.update(track)
    }
    
    func playerDidEndLoading(with track: OutputPlayerProtocol) {
        model.update(track)
    }
    
    func playerUpdatePlayingInformation(with track: OutputPlayerProtocol) {
        model.update(track)
    }
    
    func playerStateDidChanged(with track: OutputPlayerProtocol) {
        model.update(track)    }
    
    func addObserverPlayerEventNotification() {
        player.addObserverPlayerEventNotification(for: self)
    }
}
