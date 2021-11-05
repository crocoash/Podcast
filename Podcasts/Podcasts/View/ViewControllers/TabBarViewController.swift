

import UIKit

class TabBarViewController: UITabBarController {
    
    // MARK: - View
    lazy var searchVC: SearchViewController = {
        let searchVC = storyboard?.instantiateViewController(withIdentifier: SearchViewController.identifier) as! SearchViewController
        searchVC.tabBarItem.title = "Search"
        searchVC.delegate = playerVC
        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        return searchVC
    }()
    
    lazy var settingsVC: SettingsTableViewController = {
        let searchVC = storyboard?.instantiateViewController(withIdentifier: SettingsTableViewController.identifier) as! SettingsTableViewController
        searchVC.tabBarItem.title = "Settings"
        searchVC.setUser(userViewModel)
        searchVC.tabBarItem.image = UIImage(systemName: "gear")
        return searchVC
    }()
    
    lazy var playListVc: PlaylistTableViewController = {
        let playListVc =  storyboard?.instantiateViewController(withIdentifier: PlaylistTableViewController.identifier) as! PlaylistTableViewController
        playListVc.navigationItem.title = "Playlist"
        playListVc.delegate = playerVC
        return playListVc
    }()
    
    //constraintsSmallPlayer
    lazy var constraintsSmallPlayer: [NSLayoutConstraint] = [
        playerVC.view.heightAnchor.constraint(equalTo: tabBar.heightAnchor),
        playerVC.view.widthAnchor.constraint(equalTo: view.widthAnchor),
        playerVC.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
    ]
    
    private var playerVC = PlayerViewController()
    private var userViewModel: UserViewModel!
    
    func setUserViewModel(_ userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
    }
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        configureGesture()
        addPlayer()
    }
    
    // MARK: - Actions
    @objc func handlerSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left: selectedIndex += 1
        case .right: selectedIndex -= 1
        default: break
        }
    }
}

//MARK: - Private methods
extension TabBarViewController {
    
    private func configureTabBar() {
        let navigationVC = UINavigationController(rootViewController: playListVc)
        navigationVC.tabBarItem.title = "Playlist"
        navigationVC.tabBarItem.image = UIImage(systemName: "book")

        viewControllers = [searchVC, navigationVC, settingsVC]
    }
    
    private func addPlayer() {
        self.addChild(playerVC)
        view.addSubview(playerVC.view)
        playerVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraintsSmallPlayer)
    }
    
    private func configureGesture() {
        view.addMyGestureRecognizer(self, type: .swipe(directions: [.left, .right]), selector: #selector(handlerSwipe))
    }
    
   
}
