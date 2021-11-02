//
//  NewPlayerViewController.swift
//  test
//
//  Created by mac on 30.10.2021.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    @IBOutlet private weak var podcastImageView: UIImageView!
    @IBOutlet private weak var podcastNameLabel: UILabel!
    @IBOutlet private weak var autorNameLabel: UILabel!
    @IBOutlet private weak var progressSlider: UISlider!
    
    private var player: AVQueuePlayer?
    var playingPoscast: Podcast?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()
        createPlayer()
        addPlayerTimeObservers()
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
    
    private func addSwipeGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipe))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
    }
    
    @objc func respondToSwipe(gesture: UISwipeGestureRecognizer) {
        let bigPlayerVC = BigPlayerViewController(nibName: "BigPlayerViewController", bundle: nil)
        bigPlayerVC.modalPresentationStyle = .fullScreen
        present(bigPlayerVC, animated: true, completion: nil)
    }
    
    private func createPlayer() {
        let url = URL(string: "https://s3.amazonaws.com/kargopolov/kukushka.mp3")
        guard let url = url else { return }
        let playerItem: AVPlayerItem = AVPlayerItem(url: url)
        player = AVQueuePlayer(items: [playerItem])
    }
    
    private func addPlayerTimeObservers() {
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 60), queue: .main) { (time) in
            self.progressSlider.maximumValue = Float(self.player?.currentItem?.duration.seconds ?? 0)
            self.progressSlider.value = Float(time.seconds)
        }
    }
}
