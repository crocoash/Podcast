
import UIKit

class TabBarViewController: UITabBarController {
    private var playerView = SmallPlayerView()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        createSmallPlayer()
        playerView.delegate = self
    }
    
}

extension TabBarViewController {
    private func createSmallPlayer() {
        playerView = UINib(nibName: "SmallPlayerView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! SmallPlayerView
        playerView.configurPlayerView()
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
        let playListItem = UITabBarItem(title: "PlayList", image: nil, selectedImage: nil)
        playListVC.tabBarItem = playListItem
        self.viewControllers = [searchVC,playListVC]
    }
    
}

extension TabBarViewController: SmallPlayerViewDelegate {
    func rollUpPlayer() {
        playerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -25).isActive = true
    }
    
    
}
