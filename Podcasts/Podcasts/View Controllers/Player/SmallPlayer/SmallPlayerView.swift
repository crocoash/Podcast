//
//  NewPlayerViewController.swift
//  test
//
//  Created by mac on 30.10.2021.
//

import UIKit

@objc protocol SmallPlayerViewDelegate: AnyObject {
    func smallPlayerViewControllerSwipeOrTouch(_ smallPlayerView: SmallPlayerView)
}

@IBDesignable
class SmallPlayerView: UIView, IHaveXibAndViewModel {
    
    typealias ViewModel = SmallPlayerViewModel
    
    struct Arguments {
        var delegate: SmallPlayerViewDelegate
        var argsVM: ViewModel.Arguments
    }
    
    func viewModelChanged(_ viewModel: SmallPlayerViewModel) {}
    func viewModelChanged() {
        updateUI()
    }
    
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var trackImageView: UIImageView!
    @IBOutlet private weak var trackNameLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet weak var delegate: SmallPlayerViewDelegate!
    
    //MARK: Settings
    private var pauseImage = UIImage(systemName: "pause.fill")!
    private var playImage = UIImage(systemName: "play.fill")!
    
    private var player: Player!
    
    // MARK: - Init
    required init(container: IContainer, args input: Arguments) {
        self.player = container.resolve()
        self.delegate = input.delegate
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromXib()
        configureUI()
    }
    
    // MARK: - Actions
    @IBAction func playOrPause() {
        viewModel.player.playOrPause()
    }
    
    @objc func respondToSwipeOrTouch() {
        delegate?.smallPlayerViewControllerSwipeOrTouch(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if playPauseButton.frame.contains(touch.location(in: self)) {
                playOrPause()
            } else {
                respondToSwipeOrTouch()
            }
        }
    }
    
    func configureUI() {
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 0.3
        layer.shadowRadius = 3
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        translatesAutoresizingMaskIntoConstraints = false
        
        configureGesture()
    }
    
    func updateUI() {
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
}

//MARK: - Private methods
extension SmallPlayerView {
    
    private func configureGesture() {
        addMyGestureRecognizer(self, type: [.swipe(directions: [.up]),.tap()], #selector(respondToSwipeOrTouch))
    }
}
