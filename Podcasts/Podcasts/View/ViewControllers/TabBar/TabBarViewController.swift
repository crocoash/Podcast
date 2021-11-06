

import UIKit

class TabBarViewController: UITabBarController {
    
    // MARK: - View
    //constraintsSmallPlayer
    lazy var constraintsSmallPlayer: [NSLayoutConstraint] = [
        playerVC.view.heightAnchor.constraint(equalToConstant: 50),
        playerVC.view.widthAnchor.constraint(equalTo: view.widthAnchor),
        playerVC.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
    ]

    private var playerVC = PlayerViewController()
    private var userViewModel: UserViewModel!
    
    func setUserViewModel(_ userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
    }
    
    lazy var imageView: UIImageView =  {
        $0.image = UIImage(named: "decree")
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView())
    
    private var trailConstraint: NSLayoutConstraint?
    private var leadConstraint: NSLayoutConstraint?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        addPlayer()
        
        view.addSubview(imageView)
        
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        trailConstraint = imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -54)

        
        leadConstraint = imageView.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        leadConstraint?.isActive = true
        
        
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12).isActive = true
    }
}

//MARK: - Private methods
extension TabBarViewController {
    
    private func configureTabBar() {
        tabBar.backgroundColor = .gray
        let searchVC = createTabBar(SearchViewController.self, title: "Search", imageName: "magnifyingglass") {
            $0.delegate = self
        }

        let playListVc = createTabBar(PlaylistTableViewController.self , title: "Playlist", imageName: "magnifyingglass") {
            $0.delegate = self
        }
        
        let settingsVC = createTabBar(SettingsTableViewController.self, title: "Settings", imageName: "gear") { [weak self] vc in
            guard let self = self else { return }
            vc.setUser((self.userViewModel) )
            vc.delegate = self
        }
        
        let navigationPlaylistVc = UINavigationController(rootViewController: playListVc)
        navigationPlaylistVc.tabBarItem.title = "Playlist"
        navigationPlaylistVc.tabBarItem.image = UIImage(systemName: "book")

        viewControllers = [navigationPlaylistVc, searchVC, settingsVC]
    }
    
    private func createTabBar<T: UIViewController>(_ type: T.Type, title: String, imageName: String, completion: ((T) -> Void)? = nil) -> T {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: type)) as! T

        vc.tabBarItem.title = title
        vc.tabBarItem.image = UIImage(systemName: imageName)
        
        if let completion = completion { completion(vc) }
        
        return vc
    }
    
    private func addPlayer() {
        playerVC.view.isHidden = true
        playerVC.view.layer.borderColor = UIColor.gray.cgColor
        playerVC.view.layer.borderWidth = 0.3
        self.addChild(playerVC)
        view.addSubview(playerVC.view)
        playerVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraintsSmallPlayer)
    }
}

// MARK: - SearchViewControllerDelegate
extension TabBarViewController: SearchViewControllerDelegate {
    
    func searchViewController(_ searchViewController: SearchViewController, _ podcasts: [Podcast], didSelectIndex: Int) {
        playerVC.view.isHidden = false
        playerVC.play(podcasts: podcasts, at: didSelectIndex)
    }
}

// MARK: - SettingsTableViewControllerDelegate
extension TabBarViewController: SettingsTableViewControllerDelegate {
    func settingsTableViewControllerDarkModeDidSelect(_ settingsTableViewController: SettingsTableViewController) {
        
        self.trailConstraint?.isActive.toggle()
        self.leadConstraint?.isActive.toggle()
         
        UIView.animate(withDuration: 4, delay: 0, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            
            settingsTableViewController.darkModeSwitch.isOn.toggle()
            
            UIView.animate(withDuration: 1, delay: 0, options: []) {
                self.trailConstraint?.isActive.toggle()
                self.leadConstraint?.isActive.toggle()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func settingsTableViewControllerDidApear(_ settingsTableViewController: SettingsTableViewController) {
        self.playerVC.view.isHidden = true
    }
    
    func settingsTableViewControllerDidDisapear(_ settingsTableViewController: SettingsTableViewController) {
        if self.playerVC.currentPodcast != nil {
            self.playerVC.view.isHidden = false
        }
    }
}

// MARK: - PlaylistTableViewControllerDelegate
extension TabBarViewController: PlaylistTableViewControllerDelegate {
    
    func playlistTableViewController(_ playlistTableViewController: PlaylistTableViewController, _ podcasts: [Podcast], didSelectIndex: Int) {
        self.playerVC.view.isHidden = false
        playerVC.play(podcasts: podcasts, at: didSelectIndex)
    }
}
