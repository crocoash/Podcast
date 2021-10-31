//
//  BigPlayerView.swift
//  test
//
//  Created by mac on 31.10.2021.
//

import UIKit

class BigPlayerView: UIView {

    @IBOutlet private weak var podcastImageView: UIImageView!
    
    @IBOutlet weak var podcastNameLabel: UILabel!
    
    @IBOutlet weak var podcastAutorLabel: UILabel!
    @IBOutlet weak var timeFromStart: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!

    @IBAction func randomButton(_ sender: UIButton) {
    }
    
    @IBAction func previousTrackButton(_ sender: UIButton) {
    }
    
    @IBAction func rewindBackButton(_ sender: UIButton) {
    }
    @IBAction func playButton(_ sender: UIButton) {
    }
    
    @IBAction func rewindNextButton(_ sender: UIButton) {
    }
    
    @IBAction func nextTrackButton(_ sender: UIButton) {
    }
    @IBAction func loopButton(_ sender: UIButton) {
    }
    @IBAction func shareButton(_ sender: UIButton) {
    }
}
