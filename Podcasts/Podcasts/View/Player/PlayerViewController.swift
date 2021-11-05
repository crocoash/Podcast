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
    private var avAudioPlayer: AVAudioPlayer?
    
    private var soundTracks: [SoundTrack] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()
        addPlayerTimeObservers()
        playMusic()
    }
    @IBAction func changeCurentTimeSlider(_ sender: UISlider) {
        //avAudioPlayer?.stop()
        avAudioPlayer?.currentTime = TimeInterval(progressSlider.value)
        avAudioPlayer?.prepareToPlay()
        avAudioPlayer?.play()
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
//        player = AVPlayer(playerItem: soundTracks[currentPodcastIndex].playerItem)
//        player?.play()
        playerQueue = AVQueuePlayer(items: playerItems)
        //playerQueue?.play()
        

    }
    
    private func addPlayerTimeObservers() {
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 60), queue: .main) { (time) in
            self.progressSlider.maximumValue = Float(self.player?.currentItem?.duration.seconds ?? 0)
            self.progressSlider.value = Float(time.seconds)
        }
    }
    
    func downLoadAndPlay(from url: URL?) {
        if let audioUrl = url {

            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)

            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                do {
                    self.avAudioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
                        avAudioPlayer!.prepareToPlay()
                        avAudioPlayer!.volume = 1
                    self.avAudioPlayer?.delegate = self
                        avAudioPlayer!.play()
                    } catch {
                        print(error)
                    }
                // if the file doesn't exist
            } else {
                let task = URLSession.shared.downloadTask(with: audioUrl) { (location, response, error) in
                    guard let location = location else {return}
                    do{
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                        self.avAudioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
                        self.avAudioPlayer!.prepareToPlay()
                        self.avAudioPlayer!.volume = 1
                        self.avAudioPlayer?.delegate = self
                        self.avAudioPlayer!.play()
                    }
                    catch {
                        print("error")
                    }
                }
                task.resume()
            }
        }
        progressSlider.maximumValue = Float(avAudioPlayer!.duration)
        
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
        //createPlaylist()
        //playMusic()
        downLoadAndPlay(from: URL(string: podcasts[index].episodeUrl!))
    }
    
}

extension PlayerViewController : PlaylistTableViewControllerDelegate {
    func playlistTableViewController(_ playlistTableViewController: PlaylistTableViewController, play podcasts: [Podcast], at index: Int) {
        //playlistOfPodcasts = podcasts
        //podcastIndex = index
    }
}

extension PlayerViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true {
            print("hi!")
        downLoadAndPlay(from: URL(string: incomingPodcasts[currentPodcastIndex! + 1].episodeUrl!))
        print("hi!")
        } else {
            print("Hello")
        }
    }
}
