//
//  TabBarViewController.swift
//  Podcasts
//
//  Created by mac on 25.10.2021.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.viewControllers = []
        tabBar.bounds.height
        
        showPlayer()
    }
    
}

extension TabBarViewController {
    private func showPlayer() {
        let playerView = UINib(nibName: "SmallPlayerView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! SmallPlayerView
        playerView.configurPlayer()
        view.addSubview(playerView)
    }
}
