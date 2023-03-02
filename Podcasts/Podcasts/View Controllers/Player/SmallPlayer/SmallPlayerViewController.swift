//
//  NewPlayerViewController.swift
//  test
//
//  Created by mac on 30.10.2021.
//

import UIKit
import AVFoundation
import CoreData
import MediaPlayer

protocol SmallPlayerViewControllerDelegate: AnyObject {
    func smallPlayerViewControllerSwipeOrTouch(_ smallPlayerViewController: SmallPlayerViewController)
    func smallPlayerViewControllerDidTouchPlayStopButton(_ smallPlayerViewController: SmallPlayerViewController)
}

protocol SmallPlayerPlayableProtocol {
    var trackImage: String? { get }
    var trackName: String? { get }
    var progress: Double? { get }
    var isPlaying: Bool { get }
}

class SmallPlayerViewController: UIViewController {
    
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var trackImageView: UIImageView!
    @IBOutlet private weak var trackNameLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var progressView: UIProgressView!
    
    //MARK: - Settings
    private var pauseImage = UIImage(systemName: "pause.fill")!
    private var playImage = UIImage(systemName: "play.fill")!
    weak var delegate: SmallPlayerViewControllerDelegate?
    
    func playerIsGoingPlay(player: SmallPlayerPlayableProtocol) {
        if player.progress == 0 { progressView.progress = 1 }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        trackNameLabel.text = player.trackName
        DataProvider.shared.downloadImage(string: player.trackImage) { [weak self] image in
            self?.trackImageView.image = image
        }
    }
    
    func playerIsEndLoading(player: SmallPlayerPlayableProtocol) {
        activityIndicator.stopAnimating()
    }
    
    func setPlayStopButton(player: SmallPlayerPlayableProtocol) {
        let image = player.isPlaying ? pauseImage : playImage
        playPauseButton.setImage(image, for: .normal)
    }
    
    func updateProgressView(player: SmallPlayerPlayableProtocol) {
        progressView.progress = Float(player.progress ?? 0)
    }
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGesture()
    }
    
    // MARK: - Actions
    
    @IBAction func playOrPause() {
        delegate?.smallPlayerViewControllerDidTouchPlayStopButton(self)
    }
    
    @objc func respondToSwipeOrTouch(gesture: UIGestureRecognizer) {
        delegate?.smallPlayerViewControllerSwipeOrTouch(self)
    }
}

//MARK: - Private methods
extension SmallPlayerViewController {
    
    private func configureGesture() {
        addMyGestureRecognizer(self, type: .swipe(directions: [.up]), #selector(respondToSwipeOrTouch))
        addMyGestureRecognizer(self, type: .tap()                   , #selector(respondToSwipeOrTouch))
    }
}
