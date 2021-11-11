

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
        
        configureImageDarkMode()
    }
}

//MARK: - Private methods
extension TabBarViewController {
    
    private func configureTabBar() {

        let playListVc = createTabBar(PlaylistViewController.self , title: "Playlist", imageName: "folder.fill") {
            $0.delegate = self
        }
        
        let searchVC = createTabBar(SearchViewController.self, title: "Search", imageName: "magnifyingglass") {
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

        viewControllers = [playListVc, searchVC, likedMoments, settingsVC]
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
    
    private func configureImageDarkMode() {
        view.addSubview(imageView)
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        trailConstraint = imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -54)
        leadConstraint = imageView.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        leadConstraint?.isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
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
    
    func settingsTableViewControllerDarkModeDidSelect(_ settingsTableViewController: SettingsTableViewController) {
        
        self.trailConstraint?.isActive.toggle()
        self.leadConstraint?.isActive.toggle()
         
        UIView.animate(withDuration: 2, delay: 0, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            
            settingsTableViewController.switchDarkMode()
            
            UIView.animate(withDuration: 0.5, delay: 0, options: []) {
                self.trailConstraint?.isActive.toggle()
                self.leadConstraint?.isActive.toggle()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func settingsTableViewControllerDidAppear(_ settingsTableViewController: SettingsTableViewController) {
        self.playerVC.view.isHidden = true
    }
    
    func settingsTableViewControllerDidDisappear(_ settingsTableViewController: SettingsTableViewController) {
        if self.playerVC.currentPodcast != nil {
            self.playerVC.view.isHidden = false
        }
    }
}

//MARK: - LikedMomentsViewControllerDelegate
extension TabBarViewController: LikedMomentsViewControllerDelegate {
    func likedMomentViewController(_ likedMomentViewController: LikedMomentsViewController, didSelectMomentAt index: Int) {
        let allLikedMoments: [LikedMoment] = LikedMomentsManager.shared().getLikedMomentsFromUserDefault()
        playerVC.view.isHidden = false
        playerVC.playMomentWith(atIndex: index, from: allLikedMoments)
    }
    
}
