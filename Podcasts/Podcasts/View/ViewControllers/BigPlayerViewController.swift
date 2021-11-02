//
//  BigPlayerViewController.swift
//  Podcasts
//
//  Created by mac on 01.11.2021.
//

import UIKit

class BigPlayerViewController: UIViewController {

    @IBOutlet private weak var podcastImageView: UIImageView!
    @IBOutlet private weak var podcastNameLabel: UILabel!
    @IBOutlet private weak var autorNameLabel: UILabel!
    @IBOutlet private weak var passedTimeLabel: UILabel!
    @IBOutlet private weak var timeToEndLabel: UILabel!
    @IBOutlet private weak var progressSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()

    }
    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
    }
    @IBAction func previousPodcastTouchUpInside(_ sender: UIButton) {
    }
    @IBAction func tenSecondBackTouchUpInside(_ sender: UIButton) {
    }
    @IBAction func playPauseTouchUpInside(_ sender: UIButton) {
    }
    @IBAction func tenSecondForwardTouchUpInside(_ sender: UIButton) {
    }
    @IBAction func nextPodcastTouchUpInside(_ sender: UIButton) {
    }
    
    private func addSwipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipe))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    
}
    @objc func respondToSwipe(gesture: UISwipeGestureRecognizer) {
            dismiss(animated: true, completion: nil)
    }
}
