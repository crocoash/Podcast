//
//  NewPlayerViewController.swift
//  test
//
//  Created by mac on 30.10.2021.
//

import UIKit

@objc protocol SmallPlayerViewControllerDelegate: AnyObject {
    func smallPlayerViewControllerSwipeOrTouch(_ smallPlayerView: SmallPlayerView)
}

protocol SmallPlayerPlayableProtocol {
    var imageForSmallPlayer: String? { get }
    var trackName: String? { get }
    var listeningProgress: Double? { get }
    var isPlaying: Bool { get }
    var isGoingPlaying: Bool { get }
    var trackId: String { get }
}

struct SmallPlayerViewModel: SmallPlayerPlayableProtocol {
    var isGoingPlaying: Bool = true
    var imageForSmallPlayer: String?
    var trackName: String?
    var listeningProgress: Double?
    var isPlaying: Bool = false
    var trackId: String
    
    init(_ entity: SmallPlayerPlayableProtocol) {
        self.imageForSmallPlayer = entity.imageForSmallPlayer
        self.trackName = entity.trackName
        self.listeningProgress = entity.listeningProgress
        self.trackId = entity.trackId
        self.imageForSmallPlayer = entity.imageForSmallPlayer
    }
    
    mutating func updatePlayableInformation(_ input: Any) {
        
        if let player = input as? SmallPlayerPlayableProtocol {
            self.imageForSmallPlayer = player.imageForSmallPlayer
            self.trackName = player.trackName
            self.listeningProgress = player.listeningProgress
            self.isPlaying = player.isPlaying
            self.isGoingPlaying = player.isGoingPlaying
        }
    }
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
    
    private(set) var model: SmallPlayerViewModel! {
        didSet {
            updateView()
        }
    }
    
    private var player: PlayerInput!
    
    // MARK: - Init
    init<T: SmallPlayerViewControllerDelegate>(vc: T, frame: CGRect = .zero, model: SmallPlayerViewModel, player: PlayerInput) {
        self.model = model
        self.player = player
        self.delegate = vc
        
        super.init(frame: frame)
        
        initial()
        self.player.delegate = self
        updateView()
    }
    
    func configure(with model: SmallPlayerPlayableProtocol, player: PlayerInput) {
        let model = SmallPlayerViewModel(model)
        self.model = model
        self.player = player
        
        self.player.delegate = self
        updateView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initial()
    }
   
    private func initial() {
        loadFromXib()
        configureView()
        configureGesture()
    }
    
    // MARK: - Actions
    @IBAction func playOrPause() {
        player.playOrPause()
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
    
    private func updateView() {
        if model.listeningProgress == 0 {
            progressView.progress = 1
        } else {
            progressView.progress = Float(model.listeningProgress ?? 0)
        }
        
        if model.isGoingPlaying {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
        
        playPauseButton.setImage( model.isPlaying || model.isGoingPlaying ? pauseImage : playImage, for: .normal)
        
        trackNameLabel.text = model.trackName
        DataProvider.shared.downloadImage(string: model.imageForSmallPlayer) { [weak self] image in
            self?.trackImageView.image = image
        }
    }
    
    private func configureGesture() {
        addMyGestureRecognizer(self, type: [.swipe(directions: [.up]),.tap()], #selector(respondToSwipeOrTouch))
    }
}

//MARK: - PlayerEventNotification
extension SmallPlayerView: PlayerDelegate {
   
    func playerDidEndPlay(with track: OutputPlayerProtocol) {
        model.updatePlayableInformation(track)
    }
    
    func playerStartLoading(with track: OutputPlayerProtocol) {
        if model == nil {
            let model = SmallPlayerViewModel(track)
            self.model = model
        } else {
            model.updatePlayableInformation(track)
        }
    }
    
    func playerDidEndLoading(with track: OutputPlayerProtocol) {
        model.updatePlayableInformation(track)
    }
    
    func playerUpdatePlayingInformation(with track: OutputPlayerProtocol) {
        model.updatePlayableInformation(track)
    }
    
    func playerStateDidChanged(with track: OutputPlayerProtocol) {
        model.updatePlayableInformation(track)
    }
}
