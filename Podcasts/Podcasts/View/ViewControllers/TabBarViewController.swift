
import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        createSmallPlayer()
    }
    
}

extension TabBarViewController {
    private func createSmallPlayer() {
        let playerView = UINib(nibName: "SmallPlayerView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! SmallPlayerView
        playerView.configurPlayer()
        view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        playerView.heightAnchor.constraint(equalTo: tabBar.heightAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -5).isActive = true
    }
}

extension TabBarViewController {
    private func configureTabBar() {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let searchVC = main.instantiateViewController(identifier: "SearchViewControllerID") as SearchViewController
        let searchItem = UITabBarItem(title: "Search", image: nil, selectedImage: nil)
        searchVC.tabBarItem = searchItem
        let playListVC = main.instantiateViewController(identifier: "PlaylistTableViewControllerID") as PlaylistTableViewController
        let playList = UITabBarItem(title: "PlayList", image: nil, selectedImage: nil)
        playListVC.tabBarItem = playList
        self.viewControllers = [searchVC,playListVC]
    }
}
