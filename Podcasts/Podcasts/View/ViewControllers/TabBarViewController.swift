

import UIKit

class TabBarViewController: UITabBarController {
    

    private var playerVC = PlayerViewController()
    private var userViewModel: UserViewModel!
    
    func setUserViewModel(_ userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
    }
    
    lazy var constraintsSmallPlayer: [NSLayoutConstraint] = [
        playerVC.view.heightAnchor.constraint(equalTo: tabBar.heightAnchor),
        playerVC.view.widthAnchor.constraint(equalTo: view.widthAnchor),
        playerVC.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
    ]
    
    lazy var searchVC: SearchViewController = {
        let searchVC = storyboard?.instantiateViewController(withIdentifier: SearchViewController.identifier) as! SearchViewController
        searchVC.tabBarItem.title = "Search"
        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        searchVC.delegate = playerVC
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        addPlayer()
    }
    
    private func configureTabBar() {
        let navigationVC = UINavigationController(rootViewController: playListVc)
        navigationVC.tabBarItem.title = "Playlist"
        navigationVC.tabBarItem.image = UIImage(systemName: "book")

        viewControllers = [searchVC, navigationVC, settingsVC]
    }
    
    private func addPlayer() {
        self.addChild(playerVC)
        view.addSubview(playerVC.view)
        playerVC.didMove(toParent: self)
        playerVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraintsSmallPlayer)
    }
    
    
}
