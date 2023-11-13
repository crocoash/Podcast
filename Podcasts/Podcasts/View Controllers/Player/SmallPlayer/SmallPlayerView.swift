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

@IBDesignable
class SmallPlayerView: UIView, IHaveViewModel {
    
    func viewModelChanged(_ viewModel: SmallPlayerViewModel) {
        
    }
    
    func viewModelChanged() {
        updateView()
    }
    
    typealias ViewModel = SmallPlayerViewModel
    
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var trackImageView: UIImageView!
    @IBOutlet private weak var trackNameLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet weak var delegate: SmallPlayerViewControllerDelegate!
    
    //MARK: Settings
    private var pauseImage = UIImage(systemName: "pause.fill")!
    private var playImage = UIImage(systemName: "play.fill")!
    
    private var player: Player!
    
    // MARK: - Init
    init<T: SmallPlayerViewControllerDelegate>(vc: T, frame: CGRect = .zero, model: SmallPlayerViewModel, player: Player) {
        self.player = player
        self.delegate = vc
        
        super.init(frame: frame)
       
        initial()
        viewModel = model
        player.delegate = model
    }
    
    func configure(with model: SmallPlayerPlayableProtocol, player: Player) {
        let model = SmallPlayerViewModel(model)
        self.viewModel = model
        self.player = player
        
        self.player.delegate = viewModel
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
        if viewModel.listeningProgress == 0 {
            progressView.progress = 1
        } else {
            progressView.progress = Float(viewModel.listeningProgress ?? 0)
        }
        
        if viewModel.isGoingPlaying {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
        
        playPauseButton.setImage( viewModel.isPlaying || viewModel.isGoingPlaying ? pauseImage : playImage, for: .normal)
        
        trackNameLabel.text = viewModel.trackName
        DataProvider.shared.downloadImage(string: viewModel.imageForSmallPlayer) { [weak self] image in
            self?.trackImageView.image = image
        }
    }
    
    private func configureGesture() {
        addMyGestureRecognizer(self, type: [.swipe(directions: [.up]),.tap()], #selector(respondToSwipeOrTouch))
    }
}
