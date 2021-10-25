//
//  TabBarViewController.swift
//  Podcasts
//
//  Created by mac on 25.10.2021.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewWillAppear(_ animated: Bool) {
        createPlayer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    func createPlayer() {

        let viewOverTabBar = UIView(frame: CGRect(x: 0, y: self.tabBar.frame.origin.y-120, width: self.tabBar.frame.size.width, height: 20))
        //let viewOverTabBar = UIView(frame: CGRect(x: 0, y: self.tabBar.bounds.origin.y-10, width: self.tabBar.frame.size.width, height: 80))
            viewOverTabBar.backgroundColor = UIColor.systemPink
        
        

            //viewOverTabBar.layer.cornerRadius = viewOverTabBar.frame.size.height/2
            viewOverTabBar.layer.masksToBounds = false
            viewOverTabBar.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
            viewOverTabBar.layer.shadowRadius = 5.0
            viewOverTabBar.layer.shadowOffset = CGSize(width: 0.0, height: -5.0)
            viewOverTabBar.layer.shadowOpacity = 0.5

            //tabBar.addSubview(viewOverTabBar)
            view.addSubview(viewOverTabBar)
        }
}
