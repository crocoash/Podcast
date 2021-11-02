

import UIKit

class TabBarViewController: UITabBarController {
    
    private var playerVC = PlayerViewController()
    
    lazy var constraintsSmallPlayer: [NSLayoutConstraint] = [
        playerVC.view.heightAnchor.constraint(equalTo: tabBar.heightAnchor),
        playerVC.view.widthAnchor.constraint(equalTo: view.widthAnchor),
        playerVC.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
    ]
    
    lazy var searchVC: SearchViewController = {
        let searchVC = storyboard?.instantiateViewController(withIdentifier: SearchViewController.identifier) as! SearchViewController
        searchVC.tabBarItem.title = "Search"
        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        return searchVC
    }()
    
    lazy var playListVc: PlaylistTableViewController = {
        let playListVc =  storyboard?.instantiateViewController(withIdentifier: PlaylistTableViewController.identifier) as! PlaylistTableViewController
        playListVc.navigationItem.title = "Playlist"
        return playListVc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        addPlayer()
    }
    
    private func configureTabBar() {

        let main = UIStoryboard(name: "Main", bundle: nil)
        let searchVC = main.instantiateViewController(identifier: "SearchViewController") as SearchViewController
        let searchItem = UITabBarItem(title: "Search", image: nil, selectedImage: nil)
        searchVC.tabBarItem = searchItem
        let playListVC = main.instantiateViewController(identifier: "PlaylistTableViewController") as PlaylistTableViewController
        let playListItem = UITabBarItem(title: "PlayList", image: nil, selectedImage: nil)
        playListVC.tabBarItem = playListItem
        viewControllers = [searchVC,playListVC]

        let navigationVC = UINavigationController(rootViewController: playListVc)
        navigationVC.tabBarItem.title = "Playlist"
        navigationVC.tabBarItem.image = UIImage(systemName: "book")
        
    }
    
    private func addPlayer() {
        self.addChild(playerVC)
        view.addSubview(playerVC.view)
        playerVC.didMove(toParent: self)
        playerVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraintsSmallPlayer)
    }
    
}
