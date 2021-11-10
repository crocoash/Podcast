

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
    private var userViewModel: UserDocument!
    
    func setUserViewModel(_ userViewModel: UserDocument) {
        self.userViewModel = userViewModel
    }
    
    private var trailConstraint: NSLayoutConstraint?
    private var leadConstraint: NSLayoutConstraint?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        addPlayer()
    }
}

//MARK: - Private methods
extension TabBarViewController {
    
    private func configureTabBar() {

        let searchVC = createTabBar(SearchViewController.self, title: "Search", imageName: "magnifyingglass") {
            $0.delegate = self
        }

        let playListVc = createTabBar(PlaylistViewController.self , title: "Playlist", imageName: "magnifyingglass") {
            $0.delegate = self
        }
        
        let likedMoments = createTabBar(LikedMomentsViewController.self , title: "Liked", imageName: "heart.fill") {
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
        
        let navigationSearchVc = UINavigationController(rootViewController: searchVC)
        navigationSearchVc.tabBarItem.title = "Search"
        navigationSearchVc.tabBarItem.image = UIImage(systemName: "magnifyingglass")

        viewControllers = [navigationPlaylistVc, navigationSearchVc, likedMoments, settingsVC]
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
        playerVC.view.layer.shadowRadius = 3
        playerVC.view.layer.shadowColor = UIColor.black.cgColor
        playerVC.view.layer.shadowOpacity = 1
        playerVC.view.layer.shadowOffset = .zero
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

// MARK: - PlaylistTableViewControllerDelegate
extension TabBarViewController: PlaylistViewControllerDelegate {
    
    func playlistTableViewController(_ playlistTableViewController: PlaylistViewController, _ podcasts: [Podcast], didSelectIndex: Int) {
        playerVC.view.isHidden = false
        playerVC.play(podcasts: podcasts, at: didSelectIndex)
    }
}

// MARK: - SettingsTableViewControllerDelegate
extension TabBarViewController: SettingsTableViewControllerDelegate {
    
    func settingsTableViewControllerDidApear(_ settingsTableViewController: SettingsTableViewController) {
        self.playerVC.view.isHidden = true
    }
    
    func settingsTableViewControllerDidDisapear(_ settingsTableViewController: SettingsTableViewController) {
        if self.playerVC.currentPodcast != nil {
            self.playerVC.view.isHidden = false
        }
    }
}

//MARK: - LikedMomentsViewControllerDelegate
extension TabBarViewController: LikedMomentsViewControllerDelegate {
    func likedMomentViewController(_ likedMomentViewController: LikedMomentsViewController, didSelect moment: LikedMoment) {
        playerVC.view.isHidden = false
        playerVC.play(moment: moment)
    }
}
