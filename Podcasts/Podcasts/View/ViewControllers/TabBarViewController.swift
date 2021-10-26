
import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.viewControllers = []
        setupAndAppearPlayer()
    }
    
}

extension TabBarViewController {
    private func setupAndAppearPlayer() {
        let playerView = UINib(nibName: "SmallPlayerView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! SmallPlayerView
        playerView.configurPlayer()
        view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        playerView.heightAnchor.constraint(equalTo: tabBar.heightAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -5).isActive = true
        
        
    }
}
