//
//  UIViewController + identifier.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 30.10.2021.
//

import UIKit

extension UIViewController {
    
    static var identifier: String {
        return "\(Self.self)"
    }
}

extension UIView {
    
    static var identifier: String {
        return "\(Self.self)"
    }
}

