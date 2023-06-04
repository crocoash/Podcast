//
//  SearchCollectionHeaderReusableView.swift
//  Podcasts
//
//  Created by Anton on 11.05.2023.
//

import UIKit

class SearchCollectionHeaderReusableView: UICollectionReusableView {

    @IBOutlet private weak var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUp(title: String) {
        self.titleLabel.text = title
    }
}
