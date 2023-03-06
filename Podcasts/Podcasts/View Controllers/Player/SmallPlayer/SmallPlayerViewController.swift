//
//  NewPlayerViewController.swift
//  test
//
//  Created by mac on 30.10.2021.
//

import UIKit

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

@IBDesignable
class SmallPlayerViewController: UIView {
    
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var trackImageView: UIImageView!
    @IBOutlet private weak var trackNameLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var progressView: UIProgressView!
    
    //MARK: Settings
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
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
        configureView()
        configureGesture()
    }
    
    required init?(coder: NSCoder) {
      super.init(coder: coder)
        loadFromXib()
        configureView()
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
