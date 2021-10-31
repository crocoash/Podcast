//
//  TestView.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 31.10.2021.
//

import UIKit


@IBDesignable class TestView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
    }
}
