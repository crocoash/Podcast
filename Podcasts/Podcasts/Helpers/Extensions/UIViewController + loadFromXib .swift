//
//  UIStoryboard.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 07.03.2022.
//

import UIKit

extension UIViewController {
    
    static var loadFromStoryboard: Self {
        return UIStoryboard(name: Self.identifier, bundle: nil).instantiateViewController(withIdentifier: Self.identifier) as! Self
    }
    
    static var loadFromXib: Self {
        return Self(nibName: Self.identifier, bundle: nil)
    }
    
    static var storyboard: UIStoryboard {
        UIStoryboard.init(name: Self.identifier, bundle: nil)
    }
    
    static func create(creator: @escaping ((NSCoder) -> UIViewController?)) -> Self {
        let vc = Self.storyboard.instantiateViewController(identifier: Self.identifier) { coder in
            return creator(coder)
        }
        guard let vc = vc as? Self else { fatalError() }
        
        return vc
    }
}
