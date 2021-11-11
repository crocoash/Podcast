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
    @IBOutlet private weak var durationTrackLabel: UILabel!
    
    @IBOutlet private weak var progressSlider: UISlider!
    
    @IBOutlet private weak var previousPodcastButton: UIButton!
    @IBOutlet private weak var nextPodcastButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
    
    func setPlayStopButton(with image: UIImage) {
        playStopButton.setImage(image, for: .normal)
    }
    
    func upDateProgressSlider(currentTime: Float, currentItem: Float) {
        currentTimeLabel.text = convertToReadableFormat(time: currentTime)
        
        self.progressSlider.value = currentTime
        progressSlider.maximumValue = currentItem
        durationTrackLabel.text = convertToReadableFormat(time: currentItem)

        if !activityIndicator.isHidden { activityIndicator.stopAnimating() }
    }
    
    func upDateUI(with podcast: Podcast, isFirst: Bool, isLast: Bool) {
        isPresented = true
        self.isLast = isLast
        self.isFirst = isFirst
        progressSlider.value = 0
        configureUI(with: podcast)
    }
    

    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
        delegate?.bigPlayerViewController(self, didChangeCurrentTime:  Double(sender.value))
    }
    
    @IBAction func playPauseTouchUpInside(_ sender: UIButton) {
        delegate?.bigPlayerViewControllerDidSelectStopButton(self)
    }
    
    @IBAction func nextPodcastTouchUpInside(_ sender: UIButton) {
        activityIndicator.startAnimating()
        print("print nextPodcastTouchUpInside")
        durationTrackLabel.text = "0:0"
        delegate?.bigPlayerViewControllerDidSelectNextTrackButton(self)
    }
    
    @IBAction func previousPodcastTouchUpInside(_ sender: UIButton) {
        activityIndicator.startAnimating()
        durationTrackLabel.text = "0:0"
        delegate?.bigPlayerViewControllerDidSelectPreviewsTrackButton(self)
    }
    
    @IBAction func tenSecondBackTouchUpInside(_ sender: UIButton) {
        delegate?.bigPlayerViewController(self, didAddCurrentTimeBy: -50)
    }
    
    @IBAction func tenSecondForwardTouchUpInside(_ sender: UIButton) {
        delegate?.bigPlayerViewController(self, didAddCurrentTimeBy: 50)
    }
    
    @objc func respondToSwipe(gesture: UISwipeGestureRecognizer) {
        isPresented = false
        dismiss(animated: true)
    }
    
    @IBAction func likedButton(_ sender: UIButton) {
        delegate?.bigPlayerViewController(self, didLikeThis: Double(progressSlider.value))
    }
    @IBAction func dissmisButtonTouchUpInside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension BigPlayerViewController {
    
    private func configureUI(with podcast: Podcast) {
        
        DataProvider().downloadImage(string: podcast.artworkUrl160) { [weak self] image in
            self?.podcastImageView.image = image
        }
        
        podcastNameLabel.text = podcast.trackName
        previousPodcastButton.isEnabled = !isFirst
        nextPodcastButton.isEnabled = !isLast
    }
    
    
    private func addSwipeGesture() {
        view.addMyGestureRecognizer(self, type: .swipe(directions: [.down]), selector: #selector(respondToSwipe))
    }
    
    private func convertToReadableFormat(time: Float) -> String {

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional

        guard let formattedString = formatter.string(from: TimeInterval(time)) else { return "0:0"}
        
        switch formattedString.count {
        case 0..<2:
            return "0:0\(formattedString)"
        case 2...4:
            return "0:\(formattedString)"
        default:
            return formattedString
        }

    }
    
}
