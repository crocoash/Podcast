//
//  UICollectionView + register.swift
//  Podcasts
//
//  Created by Anton on 10.05.2023.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func register(_ cell: UICollectionViewCell.Type) {
        register(UINib(nibName: "\(cell.identifier)", bundle: nil), forCellWithReuseIdentifier: "\(cell.identifier)")
    }

    func getCell<T: UICollectionViewCell>(cell: T.Type, indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: cell.identifier, for: indexPath) as! T
    }
}
