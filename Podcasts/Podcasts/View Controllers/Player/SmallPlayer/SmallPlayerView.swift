//
//  NewPlayerViewController.swift
//  test
//
//  Created by mac on 30.10.2021.
//

import UIKit

@objc protocol SmallPlayerViewControllerDelegate: AnyObject {
    func smallPlayerViewControllerSwipeOrTouch(_ smallPlayerView: SmallPlayerView)
    func smallPlayerViewControllerDidTouchPlayStopButton(_ smallPlayerView: SmallPlayerView)
}

protocol SmallPlayerPlayableProtocol {
    var trackImage: String? { get }
    var trackName: String? { get }
    var progress: Double? { get }
    var isPlaying: Bool { get }
}

@IBDesignable
class SmallPlayerView: UIView {
    
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var trackImageView: UIImageView!
    @IBOutlet private weak var trackNameLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet weak var delegate: SmallPlayerViewControllerDelegate!
    
    //MARK: Settings
    private var pauseImage = UIImage(systemName: "pause.fill")!
    private var playImage = UIImage(systemName: "play.fill")!
   
    
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
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
        configureView()
        addObserverPlayerEventNotification()
        configureGesture()
    }
    
    required init?(coder: NSCoder) {
      super.init(coder: coder)
        loadFromXib()
        configureView()
        addObserverPlayerEventNotification()
        configureGesture()
    }
    
    deinit {
        removeObserverEventNotification()
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
extension SmallPlayerView {

    private func configureView() {
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 0.3
        layer.shadowRadius = 3
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureGesture() {
        addMyGestureRecognizer(self, type: .swipe(directions: [.up]), #selector(respondToSwipeOrTouch))
        addMyGestureRecognizer(self, type: .tap()                   , #selector(respondToSwipeOrTouch))
    }
}

extension SmallPlayerView: PlayerEventNotification {

    func addObserverPlayerEventNotification() {
        Player.addObserverPlayerPlayerEventNotification(for: self)
    }
    
    func removeObserverEventNotification() {
        Player.removeObserverEventNotification(for: self)
    }
    
    func playerDidEndPlay(notification: NSNotification) {
        
    }
    
    func playerStartLoading(notification: NSNotification) {
        guard let player = notification.object as? SmallPlayerPlayableProtocol else { return }
        playerIsGoingPlay(player: player)
    }
    
    func playerDidEndLoading(notification: NSNotification) {
        guard let player = notification.object as? SmallPlayerPlayableProtocol else { return }
        playerIsEndLoading(player: player)
    }
    
    func playerUpdatePlayingInformation(notification: NSNotification) {
        guard let player = notification.object as? SmallPlayerPlayableProtocol else { return }
        progressView.progress = Float(player.progress ?? 0)
    }
    
    func playerStateDidChanged(notification: NSNotification) {
        guard let player = notification.object as? SmallPlayerPlayableProtocol else { return }
        let image = player.isPlaying ? pauseImage : playImage
        playPauseButton.setImage(image, for: .normal)
    }
}
