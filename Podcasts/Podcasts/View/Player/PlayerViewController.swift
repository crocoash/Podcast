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
    
    private var player: AVPlayer?
    private var currentPodcastIndex: Int?
    private var incomingPodcasts: [Podcast] = []
    private var playerQueue: AVQueuePlayer?
    private var playerItems: [AVPlayerItem] = []
    
    private var soundTracks: [SoundTrack] = []
    
//    let url = URL(string: "https://pdst.fm/e/chtbl.com/track/479722/traffic.megaphone.fm/DGT9636625287.mp3")
//    let url2 = URL(string: "https://s3.amazonaws.com/kargopolov/kukushka.mp3")
    //var playerItems: [AVPlayerItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()
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
    

    private func playMusic() {
        guard let currentPodcastIndex = currentPodcastIndex else { return }
        player = AVPlayer(playerItem: soundTracks[currentPodcastIndex].playerItem)
        playerQueue = AVQueuePlayer(items: playerItems)

    }
    
    private func addPlayerTimeObservers() {
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 60), queue: .main) { (time) in
            self.progressSlider.maximumValue = Float(self.player?.currentItem?.duration.seconds ?? 0)
            self.progressSlider.value = Float(time.seconds)
        }
    }
    
    func createPlaylist() {
        incomingPodcasts.forEach { podcast in
            guard let stringURL = podcast.episodeUrl, let trackURL = URL(string: stringURL) else { return }
            let playerItem = AVPlayerItem(url: trackURL)
            guard let image60StringURL = podcast.artworkUrl60, let image60URL = URL(string: image60StringURL) else { return }
            guard let image600StringURL = podcast.artworkUrl600, let image600URL = URL(string: image600StringURL) else { return }
            soundTracks.append(SoundTrack(playerItem: playerItem, image60URL: image60URL, image600URL: image600URL))
            soundTracks.forEach { soundtrack in
                playerItems.append(soundtrack.playerItem)
            }
        }
    }
}

extension PlayerViewController: SearchViewControllerDelegate {
    func searchViewController(_ searchViewController: SearchViewController, play podcasts: [Podcast], at index: Int) {
        incomingPodcasts = podcasts
        currentPodcastIndex = index
        createPlaylist()
        playMusic() 
    }
    
}

extension PlayerViewController : PlaylistTableViewControllerDelegate {
    func playlistTableViewController(_ playlistTableViewController: PlaylistTableViewController, play podcasts: [Podcast], at index: Int) {
        //playlistOfPodcasts = podcasts
        //podcastIndex = index
    }
}
