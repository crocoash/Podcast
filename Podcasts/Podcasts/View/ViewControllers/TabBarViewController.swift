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
        let playListVc =  storyboard?.instantiateViewController(withIdentifier: PlaylistTableViewController.identifier) as! PlaylistTableViewController
        searchVC.tabBarItem.title = "Search"
        playListVc.tabBarItem.title = "My PlayList"

        viewControllers = [searchVC, playListVc]
//        tabBar.bounds.height
        
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

