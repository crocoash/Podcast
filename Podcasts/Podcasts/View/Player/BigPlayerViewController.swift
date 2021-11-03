//
//  BigPlayerViewController.swift
//  Podcasts
//
//  Created by mac on 01.11.2021.
//

import UIKit
import AVFoundation

class BigPlayerViewController: UIViewController {

    @IBOutlet private weak var podcastImageView: UIImageView!
    @IBOutlet private weak var podcastNameLabel: UILabel!
    @IBOutlet private weak var autorNameLabel: UILabel!
    @IBOutlet private weak var passedTimeLabel: UILabel!
    @IBOutlet private weak var timeToEndLabel: UILabel!
    @IBOutlet private weak var progressSlider: UISlider!
    
    var player: AVQueuePlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()
        addPlayerTimeObservers()
        createAudioSession()
    }
    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
        player?.seek(to: CMTime(seconds: Double(progressSlider.value), preferredTimescale: 60))
    }
    @IBAction func previousPodcastTouchUpInside(_ sender: UIButton) {
    }
    @IBAction func tenSecondBackTouchUpInside(_ sender: UIButton) {
    }
    @IBAction func playPauseTouchUpInside(_ sender: UIButton) {
        guard let player = player else { return }
        if player.rate == 0
        {
            player.play()
            
        } else {
            player.pause()
        }
    }
    @IBAction func tenSecondForwardTouchUpInside(_ sender: UIButton) {
    }
    @IBAction func nextPodcastTouchUpInside(_ sender: UIButton) {
        player?.advanceToNextItem()
    }
    
    private func addSwipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipe))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    
}
    @objc func respondToSwipe(gesture: UISwipeGestureRecognizer) {
            dismiss(animated: true, completion: nil)
    }
    private func addPlayerTimeObservers() {
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 60), queue: .main) { (time) in
            self.progressSlider.maximumValue = Float(self.player?.currentItem?.duration.seconds ?? 0)
            self.progressSlider.value = Float(time.seconds)
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
}
