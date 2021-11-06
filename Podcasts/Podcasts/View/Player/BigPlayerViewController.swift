//
//  BigPlayerViewController.swift
//  Podcasts
//
//  Created by mac on 01.11.2021.
//

import UIKit
import AVFoundation

protocol BigPlayerViewControllerDelegate: AnyObject {
    
    func bigPlayerViewControllerDidSelectStopButton (_ bigPlayerViewController: BigPlayerViewController)
    
    func bigPlayerViewControllerDidSelectNextTrackButton (_ bigPlayerViewController: BigPlayerViewController)
    
    func bigPlayerViewControllerDidSelectPreviewsTrackButton (_ bigPlayerViewController: BigPlayerViewController)
    
}

class BigPlayerViewController: UIViewController {

    @IBOutlet private weak var podcastImageView: UIImageView!
    @IBOutlet private weak var podcastNameLabel: UILabel!
    @IBOutlet private weak var authorNameLabel: UILabel!
    @IBOutlet private weak var currentTimeLabel: UILabel!
    @IBOutlet private weak var durationOfTrackLabel: UILabel!
    @IBOutlet private weak var progressSlider: UISlider!
    
    @IBOutlet private weak var previousPodcastButton: UIButton!
    @IBOutlet private weak var nextPodcastButton: UIButton!
    
    weak var delegate: BigPlayerViewControllerDelegate?
    
    private var podcast: Podcast?
    private var isLast: Bool!
    private var isFirst: Bool!
    
    func setUP(podcast: Podcast?, isLast: Bool, isFirst: Bool) {
        self.podcast = podcast
        self.isLast = isLast
        self.isFirst = isFirst
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()
        if let podcast = podcast { configureUI(with: podcast) }
        createAudioSession()
    }
    
    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
//        player?.seek(to: CMTime(seconds: Double(progressSlider.value), preferredTimescale: 60))
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
        //TODO:
    }
    
    @IBAction func tenSecondForwardTouchUpInside(_ sender: UIButton) {
        //TODO:
    }
    
    @objc func respondToSwipe(gesture: UISwipeGestureRecognizer) {
            dismiss(animated: true, completion: nil)
    }
}


extension BigPlayerViewController {
    
    func upDateUI(with podcast: Podcast?) {
        guard let podcast = podcast else { return }
        configureUI(with: podcast)
    }
    
    private func configureUI(with podcast: Podcast) {
        podcastImageView.load(string: podcast.artworkUrl600)
        podcastNameLabel.text = podcast.trackName
        authorNameLabel.text = podcast.country
        
        previousPodcastButton.isEnabled = !isFirst
        nextPodcastButton.isEnabled = !isLast
    }
    
    private func addSwipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipe))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    }
    
    func createAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(.playback)
        } catch {
            print("error")
        }
    }
    

func convertSecondsToReadableFormat(_ seconds: Float) -> String {
        let secondsInt = Int(seconds)
        let hours = Int(seconds/3600)
        let min = Int(secondsInt % 3600 / 60)
        let sec = Int((secondsInt % 60) % 60)
    if hours > 0 {
        return ("\(hours):\(min):\(sec)")
    } else {
        return ("\(min):\(sec)")
    }
    }

extension BigPlayerViewController: PlayerViewControllerDelegate {
    func updateTrackTimeWith(duration: Float, currentTime: Float) {
        progressSlider.maximumValue = duration
        progressSlider.value = currentTime
        currentTimeLabel.text = convertSecondsToReadableFormat(currentTime)
        durationOfTrackLabel.text = convertSecondsToReadableFormat(duration)
    }

}



