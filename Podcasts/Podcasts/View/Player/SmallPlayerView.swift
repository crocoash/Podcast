
import UIKit

class SmallPlayerView: UIView {


    @IBOutlet private weak var podcastImageView: UIImageView!
    
    @IBOutlet private weak var autorLabel: UILabel!
    
    @IBOutlet private weak var episodeNameLabel: UILabel!
    
    func configurPlayer() {
        episodeNameLabel.text = "Hello"
    }
}


