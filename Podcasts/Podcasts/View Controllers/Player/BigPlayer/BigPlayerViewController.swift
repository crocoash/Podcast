//
//  BigPlayerViewController.swift
//  Podcasts
//
//  Created by mac on 01.11.2021.
//

import UIKit
import AVFoundation

protocol BigPlayerViewControllerDelegate: AnyObject {
    func bigPlayerViewControllerDidSelectPlayStopButton (_ bigPlayerViewController: BigPlayerViewController)
    func bigPlayerViewControllerDidSelectNextTrackButton (_ bigPlayerViewController: BigPlayerViewController)
    func bigPlayerViewControllerDidSelectPreviewsTrackButton (_ bigPlayerViewController: BigPlayerViewController)
    func bigPlayerViewController(_ bigPlayerViewController: BigPlayerViewController, didChangeCurrentTime  value: Double)
    func bigPlayerViewController(_ bigPlayerViewController: BigPlayerViewController, didRewindCurrentTime value: Double)
    func bigPlayerViewController(_ bigPlayerViewController: BigPlayerViewController, didLikeThis moment: Double)
    func bigPlayerViewControllerDidTouchPodcastNameLabel(_ bigPlayerViewController: BigPlayerViewController, track: InputPlayerProtocol?)
}

protocol BigPlayerPlayableProtocol {
    var playerIsLoading: Bool { get }
    var isLast: Bool { get }
    var isFirst: Bool { get }
    var isPlaying: Bool { get }
    var trackName: String? { get }
    var trackImage: String? { get }
    var currentTime: Float? { get }
    var duration: Double? { get }
    var track: InputPlayerProtocol? { get }
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
    
    private let defaultTime = "0:00"
    private var pauseImage = UIImage(systemName: "pause.fill")!
    private var playImage = UIImage(systemName: "play.fill")!
    private var bigPlayerPlayableProtocol: BigPlayerPlayableProtocol!
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGestures()
    }
    
    //MARK: Public Methods
    func upDateProgressSlider(player: BigPlayerPlayableProtocol) {
        progressSlider.value = player.currentTime ?? 0
        progressSlider.maximumValue = Float(player.duration ?? 0)
        currentTimeLabel.text = player.currentTime?.formatted ?? defaultTime
        durationTrackLabel.text = player.duration?.formatted ?? defaultTime
        if !likedButton.isEnabled { likedButton.isEnabled = true }
    }
    
    func playerEndPlay(player: BigPlayerPlayableProtocol) {
        progressSlider.value = 0
        progressSlider.maximumValue = 0
        currentTimeLabel.text = defaultTime
        durationTrackLabel.text = defaultTime
        likedButton.isEnabled = false
        
    }
    
    func playerIsEndLoading(player: BigPlayerPlayableProtocol) {
        setUpUI(with: player)
        //        activityIndicator.isHidden = false
        //        activityIndicator.startAnimating()
    }
    
    func playerIsGoingPlay(player: BigPlayerPlayableProtocol) {
        activityIndicator.stopAnimating()
    }
    
    func setUpUI(with player: BigPlayerPlayableProtocol) {
        self.bigPlayerPlayableProtocol = player
        
        progressSlider.maximumValue = Float(player.duration ?? 0)
        progressSlider.value = player.currentTime ?? 0
        
        currentTimeLabel  .text = player.currentTime?.formatted ?? defaultTime
        durationTrackLabel.text = player.duration?.formatted ?? defaultTime
        podcastNameLabel  .text = player.trackName
        
        activityIndicator.isHidden = !player.playerIsLoading
        
        DataProvider.shared.downloadImage(string: player.trackImage) { [weak self] image in
            self?.podcastImageView.image = image
        }
        
        likedButton          .isEnabled = !player.playerIsLoading
        previousPodcastButton.isEnabled = !player.isFirst
        nextPodcastButton    .isEnabled = !player.isLast
        
        setPlayPauseButton(player: player)
    }
    
    func setPlayPauseButton(player: BigPlayerPlayableProtocol) {
        playPauseButton.setImage(player.isPlaying ? pauseImage : playImage, for: .normal)
    }
    
    //MARK:  Actions
    @objc func dismissBigPlayer() {
        dismiss(animated: true)
    }
    
    @objc func tapPodcastNameLabel(sender: UITapGestureRecognizer) {
        delegate?.bigPlayerViewControllerDidTouchPodcastNameLabel(self, track: bigPlayerPlayableProtocol.track )
    }
    
    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
        delegate?.bigPlayerViewController(self, didChangeCurrentTime:  Double(sender.value))
    }
    
    @IBAction func playPauseTouchUpInside(_ sender: UIButton) {
        delegate?.bigPlayerViewControllerDidSelectPlayStopButton(self)
    }
    
    @IBAction func nextPodcastTouchUpInside(_ sender: UIButton) {
        delegate?.bigPlayerViewControllerDidSelectNextTrackButton(self)
    }
    
    @IBAction func previousPodcastTouchUpInside(_ sender: UIButton) {
        delegate?.bigPlayerViewControllerDidSelectPreviewsTrackButton(self)
    }
    
    @IBAction func tenSecondBackTouchUpInside(_ sender: UIButton) {
        delegate?.bigPlayerViewController(self, didRewindCurrentTime: -60)
    }
    
    @IBAction func tenSecondForwardTouchUpInside(_ sender: UIButton) {
        delegate?.bigPlayerViewController(self, didRewindCurrentTime: 60)
    }
    
    @objc func respondToSwipe(gesture: Any) {
        dismissBigPlayer()
    }
    
    @IBAction func likedButton(_ sender: UIButton) {
        delegate?.bigPlayerViewController(self, didLikeThis: Double(progressSlider.value))
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
}
