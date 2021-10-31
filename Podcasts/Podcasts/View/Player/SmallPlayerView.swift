
import UIKit

class SmallPlayerView: UIView {

    @IBOutlet private weak var podcastImage: UIImageView!
    @IBOutlet private weak var episodeName: UILabel!
    
    func configurPlayer() {
        episodeName.text = "Hello"
    }
}


