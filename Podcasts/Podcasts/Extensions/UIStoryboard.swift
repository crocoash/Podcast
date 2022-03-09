//
//  UIStoryboard.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 07.03.2022.
//

import Foundation
import UIKit

extension UIViewController {
    
    static var initVC: Self {
        UIStoryboard(name: Self.identifier, bundle: nil).instantiateViewController(withIdentifier: Self.identifier) as! Self
    }
}
