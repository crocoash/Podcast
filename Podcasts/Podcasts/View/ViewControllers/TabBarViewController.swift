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
}

extension TabBarViewController {
    private func showPlayer() {
        let playerView = UINib(nibName: "SmallPlayerView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! SmallPlayerView
        playerView.configurPlayer()
        view.addSubview(playerView)
    }
}
