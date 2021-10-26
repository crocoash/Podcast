//
//  SearchViewController.swift
//  Podcasts
//
//  Created by mac on 25.10.2021.
//

import UIKit

class SearchViewController : UIViewController {
    
    private var podcasts: [Podcast] = [] {
        didSet {
            print(podcasts[0])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApiService.shared.getData(for: "The+Radio+Hour") { [weak self] (info: PodcastData?) in
            guard let info = info else { return }
            self?.podcasts = info.results
        }
    }
}
