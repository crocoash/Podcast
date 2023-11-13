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

class BigPlayerViewController: UIViewController, IHaveViewModel, IHaveXib {
    
    typealias Arguments = Input
    typealias ViewModel = BigPlayerViewModel

    struct Input {
        var delegate: BigPlayerViewControllerDelegate
        var modelInput: ViewModel.Arguments
    }
    
    func viewModelChanged(_ viewModel: BigPlayerViewModel) {
        guard podcastImageView != nil else { return }
        updateUI()
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
    required init?(container: IContainer, args input: Arguments) {
        self.player = container.resolve()
        self.likeManager = container.resolve()
        
        self.delegate = input.delegate
      
        super.init(nibName: Self.identifier, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        player.delegate = viewModel
        configureGestures()
        progressSlider.addTarget(self, action: #selector(sliderValueChangedBegin), for: .editingDidBegin)
        progressSlider.addTarget(self, action: #selector(progressSliderValueChanged(slider:event:)), for: .valueChanged)
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
        viewModel.addLikeMoment()
    }
    
    @IBAction func dissmisButtonTouchUpInside(_ sender: UIButton) {
        dismissBigPlayer()
    }
}

//MARK: - PrivateMethods
extension BigPlayerViewController {
    
    private func updateUI() {
        progressSlider.maximumValue = Float(viewModel.duration ?? 0)
        progressSlider.value = Float(viewModel.currentTime ?? 0)
        
        currentTimeLabel  .text = viewModel.currentTime?.formatted
        durationTrackLabel.text = viewModel.duration?.formatted
        podcastNameLabel  .text = viewModel.trackName
        
        activityIndicator.isHidden = !viewModel.isGoingPlaying

        podcastImageView.image = viewModel.imageForBigPlayer
        likedButton          .isEnabled = !viewModel.isGoingPlaying
        previousPodcastButton.isEnabled = !viewModel.isFirst
        nextPodcastButton    .isEnabled = !viewModel.isLast
        
        playPauseButton.setImage(viewModel.isPlaying || viewModel.isGoingPlaying ? pauseImage : playImage, for: .normal)
    }
    
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

