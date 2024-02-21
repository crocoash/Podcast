//
//  UIView + loadFromNib.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 31.10.2021.
//

import UIKit

extension UIView {
    
    func loadFromXib() {
        let bundle = Bundle(for: Self.self)
        let nib = UINib(nibName: Self.identifier, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        addSubview(view)
    }
}

