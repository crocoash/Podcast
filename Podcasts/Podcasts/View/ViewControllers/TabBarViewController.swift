

import UIKit

class TabBarViewController: UITabBarController {
    
    private var newPlayerVC = PlayerViewController()
    
    
    lazy var constraintsSmallPlayer: [NSLayoutConstraint] = [
        newPlayerVC.view.heightAnchor.constraint(equalTo: tabBar.heightAnchor),
        newPlayerVC.view.widthAnchor.constraint(equalTo: view.widthAnchor),
        newPlayerVC.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -5)
    ]
    lazy var constraintsBigPlayer: [NSLayoutConstraint] = [
        newPlayerVC.view.topAnchor.constraint(equalTo: view.topAnchor),
        newPlayerVC.view.widthAnchor.constraint(equalTo: view.widthAnchor),
        newPlayerVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        addPlayer()
    }
    
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
    
    private func addPlayer() {
        self.addChild(newPlayerVC)
        

        view.addSubview(newPlayerVC.view)
        newPlayerVC.didMove(toParent: self)
        newPlayerVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraintsSmallPlayer)
        createAndAddGestures(to: newPlayerVC)

        let searchVC = storyboard?.instantiateViewController(withIdentifier: SearchViewController.identifier) as! SearchViewController
        
        searchVC.tabBarItem.title = "Search"
        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")

        let playListVc =  storyboard?.instantiateViewController(withIdentifier: PlaylistTableViewController.identifier) as! PlaylistTableViewController

        playListVc.navigationItem.title = "Playlist"
        
        let navigationVC = UINavigationController(rootViewController: playListVc)
        navigationVC.tabBarItem.title = "Playlist"
        navigationVC.tabBarItem.image = UIImage(systemName: "book")
        
        viewControllers = [searchVC, navigationVC]
        
//        showPlayer()

    }
    
    private func updatePlayerConstraints() {
        if newPlayerVC.isPlayerBig {
            NSLayoutConstraint.deactivate(constraintsBigPlayer)
            NSLayoutConstraint.activate(constraintsSmallPlayer)
        } else {
            NSLayoutConstraint.deactivate(constraintsSmallPlayer)
            NSLayoutConstraint.activate(constraintsBigPlayer)
        }
        UIView.animateKeyframes(withDuration: 0.33, delay: 0.0, options: .calculationModeLinear, animations: {self.view.layoutIfNeeded()}, completion: nil)
    }
    
    private func createAndAddGestures(to: PlayerViewController) {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipe))
        swipeUp.direction = .up
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipe))
        swipeDown.direction = .down
        [swipeUp,swipeDown].forEach { newPlayerVC.view.addGestureRecognizer($0) }
    }
    
    @objc func respondToSwipe(gesture: UISwipeGestureRecognizer) {
            switch gesture.direction {
            case .up:
                updatePlayerConstraints()
                newPlayerVC.isPlayerBig = true
            case .down:
                updatePlayerConstraints()
                newPlayerVC.isPlayerBig = false
            default:
                break
            }
    }
}
