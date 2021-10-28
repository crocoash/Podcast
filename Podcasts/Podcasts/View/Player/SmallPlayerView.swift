
import UIKit
import AVFoundation

class SmallPlayerView: UIView {


    @IBOutlet private weak var podcastImageView: UIImageView!
    
    @IBOutlet private weak var autorLabel: UILabel!
    
    @IBOutlet private weak var episodeNameLabel: UILabel!
    
    var player: AVPlayer?
    var delegate: SmallPlayerViewDelegate?
    
    func configurPlayerView() {
        episodeNameLabel.text = "Hello"
        let url = URL(string: "https://s3.amazonaws.com/kargopolov/kukushka.mp3")
        let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
        player = AVPlayer(playerItem: playerItem)
    }
    @IBAction func playPauseTouchUpInside(_ sender: Any) {
        if player?.rate == 0
        {
            player!.play()
            
            //playButton!.setImage(UIImage(named: "player_control_pause_50px.png"), forState: UIControlState.Normal)
            
        } else {
            player!.pause()
            //playButton!.setImage(UIImage(named: "player_control_play_50px.png"), forState: UIControlState.Normal)
            
        }
        delegate?.rollUpPlayer()
    }
}

protocol SmallPlayerViewDelegate {
    func rollUpPlayer()
}


