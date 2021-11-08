//
//  BigPlayerViewController.swift
//  Podcasts
//
//  Created by mac on 01.11.2021.
//

import UIKit
import AVFoundation

class BigPlayerViewController: UIViewController {
    
    @IBOutlet private weak var playStopButton: UIButton!
    @IBOutlet private weak var podcastImageView: UIImageView!
    @IBOutlet private weak var podcastNameLabel: UILabel!
    @IBOutlet private weak var currentTimeLabel: UILabel!
    @IBOutlet private weak var durationOfTrackLabel: UILabel!
    
    @IBOutlet private weak var progressSlider: UISlider!
    
    @IBOutlet private weak var previousPodcastButton: UIButton!
    @IBOutlet private weak var nextPodcastButton: UIButton!
    
    weak var delegate: BigPlayerViewControllerDelegate?
    
    private var podcast: Podcast?
    
    private(set) var isPresented: Bool = false
    
    private var isLast: Bool!
    private var isFirst: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()
        if let podcast = podcast { configureUI(with: podcast) }
    }
    
    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
        delegate?.bigPlayerViewController(self, didChangeCurrentTime:  Double(sender.value))
    }
    
    @IBAction func playPauseTouchUpInside(_ sender: UIButton) {
        delegate?.bigPlayerViewControllerDidSelectStopButton(self)
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
    
    @IBAction func likeMomentTouchUpInside(_ sender: UIButton) {
        delegate?.bigPlayerViewController(self, didLikeThisMoment: Double(progressSlider.value))
    }
    
    @objc func respondToSwipe(gesture: UISwipeGestureRecognizer) {
        isPresented = false
        dismiss(animated: true)
    }
}


extension BigPlayerViewController {
    
    func setPlayStopButton(with image: UIImage) {
        playStopButton.setImage(image, for: .normal)
    }
    
    func upDateProgressSlider(currentTime: Float) {
        currentTimeLabel.text = convertTimeToReadableFormat(currentTime)
        progressSlider.value = currentTime
    }
    
    func upDateUI(currentItem: Float, with podcast: Podcast?, isFirst: Bool, isLast: Bool) {
        isPresented = true
        guard let podcast = podcast else { return }
        self.isLast = isLast
        self.isFirst = isFirst
        
        progressSlider.maximumValue = currentItem
        durationOfTrackLabel.text = convertTimeToReadableFormat(currentItem)
        progressSlider.value = 0
        
        configureUI(with: podcast)
    }
    
    private func configureUI(with podcast: Podcast) {
        podcastImageView.load(string: podcast.artworkUrl600)
        podcastNameLabel.text = podcast.trackName
        previousPodcastButton.isEnabled = !isFirst
        nextPodcastButton.isEnabled = !isLast
    }
    
    private func addSwipeGesture() {
        view.addMyGestureRecognizer(self, type: .swipe(directions: [.down]), selector: #selector(respondToSwipe))
    }
    
    private func convertTimeToReadableFormat(_ time: Float) -> String {
        let timeInt = Int(time)
        let hours = Int(timeInt/3600)
        let min = Int(timeInt % 3600 / 60)
        let sec = Int ((timeInt % 60) % 60)
        if hours > 0 {
            return ("\(hours):\(min):\(sec)")
        } else {
            return ("\(min):\(sec)")
        }
    }
    
}



