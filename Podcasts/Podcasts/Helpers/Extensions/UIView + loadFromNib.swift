//
//  UIView + loadFromNib.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 31.10.2021.
//

import UIKit

extension UIView {
    func loadFromNib() {
        let bundle = Bundle(for: Self.self)
        let nib = UINib(nibName: "\(Self.self)", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView // FIXME: форс
        view.frame = bounds
        addSubview(view)
    }
    
    func loadFromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)!.first as! T // FIXME: форс
    }
}
