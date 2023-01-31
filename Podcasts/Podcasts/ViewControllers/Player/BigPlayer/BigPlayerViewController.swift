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
    func bigPlayerViewController(_ bigPlayerViewController: BigPlayerViewController, didAddCurrentTimeBy value: Double)
    func bigPlayerViewController(_ bigPlayerViewController: BigPlayerViewController, didLikeThis moment: Double)
}

class BigPlayerViewController: UIViewController {
    
    @IBOutlet private weak var podcastImageView:      UIImageView!
    @IBOutlet private weak var podcastNameLabel:      UILabel!
    @IBOutlet private weak var currentTimeLabel:      UILabel!
    @IBOutlet private weak var durationTrackLabel:    UILabel!
    @IBOutlet private weak var progressSlider:        UISlider!
    @IBOutlet private weak var previousPodcastButton: UIButton!
    @IBOutlet private weak var nextPodcastButton:     UIButton!
    @IBOutlet private weak var playPauseButton:        UIButton!
    @IBOutlet private weak var likedButton:           UIButton!
    @IBOutlet private weak var activityIndicator:     UIActivityIndicatorView!
    
    weak var delegate: BigPlayerViewControllerDelegate?
    
    private var podcast: Podcast?
    
    private(set) var isPresented: Bool = false
    private let defaultTime = "0:00"
    
    private var isLast: Bool!
    private var isFirst: Bool!
    
    //MARK: - ViewM ethods
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()
    }
    
    //MARK: - Public Methods
    func isPresented(_ bool: Bool) {
        self.isPresented = bool
    }
    
    func updatePlayStopButton(with playStopImage: UIImage) {
        playPauseButton.setImage(playStopImage, for: .normal)
    }
    
    func upDateProgressSlider(currentTime: Float, duration: Float) {
        progressSlider.value = currentTime
        progressSlider.maximumValue = duration
        currentTimeLabel.text = currentTime.formattedString
        durationTrackLabel.text = duration.formattedString

        if !activityIndicator.isHidden { activityIndicator.stopAnimating() }
        if !likedButton.isEnabled { likedButton.isEnabled = true }
    }
    
    func upDateUI(with podcast: Podcast, isFirst: Bool, isLast: Bool, playStopButton: UIImage) {
        self.isPresented = true
        
        if self.podcast != podcast {
            self.isLast = isLast
            self.isFirst = isFirst
            self.progressSlider.value = 0
            self.configureUI(with: podcast)
        }
        self.playPauseButton?.setImage(playStopButton, for: .normal)
        self.podcast = podcast
    }
    
    func refreshInfo() {
        activityIndicator?.startAnimating()
        likedButton?.isEnabled = false
        podcastImageView?.image = nil
        durationTrackLabel?.text = defaultTime
        currentTimeLabel?.text = defaultTime
    }
    
    //MARK: - Actions
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
        delegate?.bigPlayerViewController(self, didAddCurrentTimeBy: -50)
    }
    
    @IBAction func tenSecondForwardTouchUpInside(_ sender: UIButton) {
        delegate?.bigPlayerViewController(self, didAddCurrentTimeBy: 50)
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

extension BigPlayerViewController {
    
    private func configureUI(with podcast: Podcast) {
        
        DataProvider.shared.downloadImage(string: podcast.artworkUrl160) { [weak self] image in
            self?.podcastImageView.image = image
        }
        
        podcastNameLabel.text = podcast.trackName
        previousPodcastButton.isEnabled = !isFirst
        nextPodcastButton.isEnabled = !isLast
    }
    
    
    private func addSwipeGesture() {
        addMyGestureRecognizer(self, type: .swipe(directions: [.down]), #selector(respondToSwipe))
    }
    
    private func dismissBigPlayer() {
        isPresented = false
        dismiss(animated: true)
    }
}
