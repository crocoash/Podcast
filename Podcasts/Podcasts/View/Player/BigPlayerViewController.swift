//
//  BigPlayerViewController.swift
//  Podcasts
//
//  Created by mac on 01.11.2021.
//

import UIKit
import AVFoundation

// FIXME: Хорошее именованием делегатов, лайк и респект)

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
    
    weak var delegate: BigPlayerViewControllerDelegate?
    
    private var podcast: Podcast! 
    
    func setUP(podcast: Podcast) {
        self.podcast = podcast
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()
        configureUI(with: podcast)
        addPlayerTimeObservers()
        createAudioSession()
        displayDurationOfCurrentTrack()
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
    
    }
    
    @IBAction func tenSecondForwardTouchUpInside(_ sender: UIButton) {
    
    }
    
    @objc func respondToSwipe(gesture: UISwipeGestureRecognizer) {
            dismiss(animated: true, completion: nil)
    }
}


extension BigPlayerViewController {

    // FIXME: Почему он не приватный? И почему буква D большая?)
    func upDateUI(with podcast: Podcast) {
        configureUI(with: podcast)
    }
    
    private func configureUI(with podcast: Podcast) {
        podcastImageView.load(string: podcast.artworkUrl600)
        podcastNameLabel.text = podcast.trackName
        authorNameLabel.text = podcast.country
    }
    
    private func addSwipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipe))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    private func addPlayerTimeObservers() {
//        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 60), queue: .main) { (time) in
//            self.progressSlider.maximumValue = Float(self.player?.currentItem?.duration.seconds ?? 0)
//            self.progressSlider.value = Float(time.seconds)
//
//            let currentTime = self.player?.currentTime().seconds
//            guard let currentTimee = currentTime else {return}
//            self.currentTimeLabel.text = "\(Int(currentTimee))"
            
        }
    }
    
    func createAudioSession() {
        // FIXME: Работы с аудио сессией в отдельный сервис (менеджер)
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(.playback)
        } catch {
            print("error")
        }
    }
    
    func displayDurationOfCurrentTrack() {
//        let duration = player?.currentItem?.duration.seconds
//        guard let durationn = duration else { return }
//        self.durationOfTrackLabel.text = "\(Int(durationn))"
//    }
}



