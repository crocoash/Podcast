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
    private var podcastIndex: Int?
    private var playlistOfPodcasts: [Podcast]?
    
    let url = URL(string: "https://pdst.fm/e/chtbl.com/track/479722/traffic.megaphone.fm/DGT9636625287.mp3")
    let url2 = URL(string: "https://s3.amazonaws.com/kargopolov/kukushka.mp3")
    var playerItems: [AVPlayerItem]?
    
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
        view.addMyGestureRecognizer(self, type: .tap(1), selector: #selector(respondToSwipe))
    }
    
    @objc func respondToSwipe(gesture: UISwipeGestureRecognizer) {
        let bigPlayerVC = BigPlayerViewController(nibName: "BigPlayerViewController", bundle: nil)
        bigPlayerVC.modalPresentationStyle = .fullScreen
        bigPlayerVC.player = player
        present(bigPlayerVC, animated: true, completion: nil)
    }
    
    private func createPlayer() {
        let url = URL(string: "https://pdst.fm/e/chtbl.com/track/479722/traffic.megaphone.fm/DGT9636625287.mp3")
        playerItems = [AVPlayerItem(url: url!), AVPlayerItem(url: url2!)]
        guard let url = url else { return }
        let playerItem: AVPlayerItem = AVPlayerItem(url: url)
        player = AVQueuePlayer(items: playerItems!)
    }
    
    private func addPlayerTimeObservers() {
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 60), queue: .main) { (time) in
            self.progressSlider.maximumValue = Float(self.player?.currentItem?.duration.seconds ?? 0)
            self.progressSlider.value = Float(time.seconds)
        }
    }
}

extension PlayerViewController: SearchViewControllerDelegate {
    func searchViewController(_ searchViewController: SearchViewController, play podcasts: [Podcast], at index: Int) {
        playlistOfPodcasts = podcasts
        podcastIndex = index
    }
    
}
