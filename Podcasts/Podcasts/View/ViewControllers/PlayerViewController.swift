//
//  NewPlayerViewController.swift
//  test
//
//  Created by mac on 30.10.2021.
//

import UIKit

class PlayerViewController: UIViewController {

    @IBOutlet private weak var podcastImageView: UIImageView!
    @IBOutlet private weak var podcastNameLabel: UILabel!
    @IBOutlet private weak var autorNameLabel: UILabel!
    @IBOutlet private weak var progressSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()
    }

    @IBAction func playPauseTouchUpInside(_ sender: UIButton) {
    }
    
    private func addSwipeGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipe))
        swipeUp.direction = .up
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipe))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeUp)
    }
    
    @objc func respondToSwipe(gesture: UISwipeGestureRecognizer) {
            let bigPlayerVC = BigPlayerViewController(nibName: "BigPlayerViewController", bundle: nil)
        bigPlayerVC.modalPresentationStyle = .fullScreen
            present(bigPlayerVC, animated: true, completion: nil)
    }
    
}
