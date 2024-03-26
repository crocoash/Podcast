

import UIKit
import CoreData

class TabBarViewController: UITabBarController, IHaveStoryBoardAndViewModel {
    
    func configureUI() {}
    func updateUI() {}
    
    struct Args {}
    typealias ViewModel = TabBarViewModel
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: smallPlayer)
            if let smallPlayer = smallPlayer, smallPlayer.bounds.contains(location) {
                smallPlayer.touchesBegan(touches, with: event)
            }
        }
    }
    
    // MARK: - variables
    private var trailConstraint: NSLayoutConstraint?
    private var leadConstraint: NSLayoutConstraint?
    
    private var imageView: UIImageView = {
        $0.image = UIImage(named: "decree")
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView())
    
    private var smallPlayer: SmallPlayerView?
    private var player: Player
    private let apiService: ApiService
    private let container: IContainer
    
   //MARK: init
    required init?(container: IContainer, args: (args: Args, coder: NSCoder)) {
        self.player = container.resolve()
        self.apiService = container.resolve()
        self.container = container
        
        let _: ListDataManager = container.resolve()
        super.init(coder: args.coder)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        self.player.delegate = self
    }
}

//MARK: - Private methods
extension TabBarViewController {
    
    private func presentSmallPlayer(with track: (any OutputPlayerProtocol)) {
        guard smallPlayer == nil else { return }
        
        let smallPlayer = viewModel.getSmallPlayer(item: track)
        tabBar.addSubview(smallPlayer)
        smallPlayer.isHidden = false
        self.smallPlayer = smallPlayer
        
        smallPlayer.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor, constant: -tabBar.bounds.height).isActive = true
        smallPlayer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        smallPlayer.widthAnchor.constraint(equalTo: tabBar.widthAnchor).isActive = true
    }
    
    //MARK: configureView
    private func configureTabBar() {
        self.viewControllers = viewModel.getViewControllers()
    }
 
    private func configureImageDarkMode() {
        view.addSubview(imageView)
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        trailConstraint = imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -54)
        leadConstraint = imageView.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        leadConstraint?.isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
    }
    
    private func configureView() {
        configureTabBar()
        configureImageDarkMode()
    }
}

// MARK: - SettingsTableViewControllerDelegate
extension TabBarViewController: SettingsTableViewControllerDelegate {
    
    func settingsTableViewControllerDidAppear(_ settingsTableViewController: SettingsTableViewController) {
        self.smallPlayer?.isHidden = true
    }
    
    func settingsTableViewControllerDidDisappear(_ settingsTableViewController: SettingsTableViewController) {
        if self.player.currentTrack != nil {
            self.smallPlayer?.isHidden = false
        }
    }
}

//MARK: - PlayerEventNotification
extension TabBarViewController: PlayerDelegate {
    
    func playerStartLoading(_ player: Player, with track: any OutputPlayerProtocol) {
        presentSmallPlayer(with: track)
    }
    
    func playerDidEndPlay(_ player: Player, with track: any OutputPlayerProtocol) {}
    func playerDidEndLoading(_ player: Player, with track: any OutputPlayerProtocol) {}
    func playerUpdatePlayingInformation(_ player: Player, with track: any OutputPlayerProtocol) {}
    func playerStateDidChanged(_ player: Player, with track: any OutputPlayerProtocol) {}
}

//MARK: - UIViewControllerTransitioningDelegate
extension TabBarViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }
}
