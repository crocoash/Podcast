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
    var currentTime: Float? { get }
    var duration: Double? { get }
    var listeningProgress: Double? { get }
}

class BigPlayerViewModel: BigPlayerPlayableProtocol, IPerRequest {
    typealias Arguments = Podcast
    
    var isGoingPlaying: Bool = false
    var isLast: Bool = true
    var isFirst: Bool = true
    var isPlaying: Bool = false
    var trackName: String?
    var imageForBigPlayer: String?
    var currentTime: Float?
    var duration: Double?
    var listeningProgress: Double?
    
    required init(container: IContainer, args: Podcast) {
        self.trackName = args.trackName
        self.imageForBigPlayer = args.artworkUrl600
        self.currentTime = args.currentTime
        self.duration = args.duration
        self.listeningProgress = args.listeningProgress
    }
}

class BigPlayerViewController: UIViewController, IHaveViewModel, IPerRequest {
    
    
    func viewModelChanged(_ viewModel: BigPlayerViewModel) {
        
    }
    
    typealias Arguments = BigPlayerViewControllerDelegate
    typealias ViewModel = BigPlayerViewModel
    
    func viewModelChanged() {
        
    }

    
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

    private var player: Player
    private var likeManager: LikeManager
    
    private let defaultTime = "0:00"
    private var pauseImage = UIImage(systemName: "pause.fill")!
    private var playImage = UIImage(systemName: "play.fill")!
    
    //MARK: init
    required init(container: IContainer, args: Arguments) {
        self.player = container.resolve()
        self.likeManager = container.resolve()
        self.delegate = args
        super.init(nibName: Self.identifier, bundle: nil)
    }
       
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - PublicMethods
    
    private func configure() {
        progressSlider.maximumValue = Float(viewModel.duration ?? 0)
        progressSlider.value = Float(viewModel.currentTime ?? 0)
        
        currentTimeLabel  .text = viewModel.currentTime?.formatted
        durationTrackLabel.text = viewModel.duration?.formatted
        podcastNameLabel  .text = viewModel.trackName
        
        activityIndicator.isHidden = !viewModel.isGoingPlaying
        
        DataProvider.shared.downloadImage(string: viewModel.imageForBigPlayer) { [weak self] image in
            self?.podcastImageView.image = image
        }
        
        likedButton          .isEnabled = !viewModel.isGoingPlaying
        previousPodcastButton.isEnabled = !viewModel.isFirst
        nextPodcastButton    .isEnabled = !viewModel.isLast
        
        playPauseButton.setImage(viewModel.isPlaying || viewModel.isGoingPlaying ? pauseImage : playImage, for: .normal)
    }
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        player.delegate = self
        configureGestures()
        progressSlider.addTarget(self, action: #selector(sliderValueChangedBegin), for: .editingDidBegin)
        progressSlider.addTarget(self, action: #selector(progressSliderValueChanged(slider:event:)), for: .valueChanged)
        configure()
    }
    
    //MARK:  Actions
    @objc func dismissBigPlayer() {
        presentingViewController?.dismiss(animated: true)
    }
    
    @objc func sliderValueChangedBegin() {
        player.pause()
    }
    
    @objc func tapPodcastNameLabel(sender: UITapGestureRecognizer) {
//        delegate?.bigPlayerViewControllerDidTouchPodcastNameLabel(self, entity: viewModel.inputType)
    }
    
    @objc func progressSliderValueChanged(slider: UISlider, event: UIEvent) {
        switch event.allTouches?.first?.phase {
        case .began:
            player.pause()
        case .ended:
            progressSlider.value = slider.value
            player.playerSeek(to: Double(slider.value))
        case .moved:
            currentTimeLabel.text = Double(slider.value).formatted
        default: break
        }
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
        player.playerRewindSeek(to: -60)
    }
    
    @IBAction func tenSecondForwardTouchUpInside(_ sender: UIButton) {
        player.playerRewindSeek(to: 60)
    }
    
    @objc func respondToSwipe(gesture: Any) {
        dismissBigPlayer()
    }
    
    @IBAction func likedButton(_ sender: UIButton) {
        let moment = Double(progressSlider.value)
//        likeManager.addToLikedMoments(entity: viewModel.inputType, moment: moment)
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
extension BigPlayerViewController: PlayerDelegate {
    
    func playerDidEndPlay(_ player: Player, with track: OutputPlayerProtocol) {
//        viewModel.update(track)
    }
    
    func playerStartLoading(_ player: Player, with track: OutputPlayerProtocol) {
//        viewModel.update(track)
    }
    
    func playerDidEndLoading(_ player: Player, with track: OutputPlayerProtocol) {
//        viewModel.update(track)
    }
    
    func playerUpdatePlayingInformation(_ player: Player, with track: OutputPlayerProtocol) {
//        viewModel.update(track)
    }
    
    func playerStateDidChanged(_ player: Player, with track: OutputPlayerProtocol) {
//        viewModel.update(track)
    }
}
