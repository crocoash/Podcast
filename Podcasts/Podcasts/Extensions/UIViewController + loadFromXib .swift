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
        return Self(nibName: "\(Self.self)", bundle: nil)
    }
}
