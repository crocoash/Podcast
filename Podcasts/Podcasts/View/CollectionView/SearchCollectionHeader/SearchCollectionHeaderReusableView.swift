//
//  SearchCollectionHeaderReusableView.swift
//  Podcasts
//
//  Created by Anton on 11.05.2023.
//

import UIKit

class SearchCollectionHeaderReusableView: UICollectionReusableView {

    @IBOutlet private weak var titleLabel: UILabel!
    
    func setUp(title: String) {
        self.titleLabel.text = title
    }
}
