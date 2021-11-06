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
    
    private var isLast: Bool!
    private var isFirst: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()
        if let podcast = podcast { configureUI(with: podcast) }
        addPlayerTimeObservers()
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
        dismiss(animated: true)
    }
}


extension BigPlayerViewController {
    
    func setPlayStopButton(with image: UIImage) {
        playStopButton.setImage(image, for: .normal)
    }
    
    func upDateUI( with podcast: Podcast?, isFirst: Bool, isLast: Bool) {
        guard let podcast = podcast else { return }
        self.isLast = isLast
        self.isFirst = isFirst
        
        configureUI(with: podcast)
    }
    
    private func configureUI(with podcast: Podcast) {
        podcastImageView.load(string: podcast.artworkUrl600)
        podcastNameLabel.text = podcast.trackName
        durationOfTrackLabel.text = "\(podcast.date)"
        previousPodcastButton.isEnabled = !isFirst
        nextPodcastButton.isEnabled = !isLast
        
    }
    
    private func addSwipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipe))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    private func addPlayerTimeObservers() {
//        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 60), queue: .main) { (time) in
//            self.progressSlider.maximumValue = Float((self.player?.currentItem?.duration.seconds) ?? 0 / 60000 )
//            self.progressSlider.value = Float(time.seconds)
//            
//            let currentTime = self.player.currentTime().seconds 
//            
//            self.currentTimeLabel.text = "\(currentTime)"
//        }
    }
    
    func createAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(.playback)
        } catch {
            print("error")
        }
    }
}



