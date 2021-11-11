//
//  UIViewController + loadFromXib.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 05.11.2021.
//

import UIKit

extension UIViewController {
    static func loadFromXib() -> Self {
        return Self(nibName: String(describing: Self.self), bundle: nil)
    }
}
