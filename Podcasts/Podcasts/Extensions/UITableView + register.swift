//
//  UITableView + register.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 30.10.2021.
//

import UIKit

extension UITableView {
    func register(_ cell: UITableViewCell.Type) {
        register(UINib(nibName: "\(cell.identifier)", bundle: nil), forCellReuseIdentifier: "\(cell.identifier)")
    }
    
    static var identifier: String {
        return "\(Self.self)"
    }

    func getCell<T: UITableViewCell>(cell: T.Type, indexPath: IndexPath) -> T {
        if self.dequeueReusableCell(withIdentifier: cell.identifier) == nil {
            self.register(cell)
        }
        return self.dequeueReusableCell(withIdentifier: cell.identifier, for: indexPath) as! T
    }
}
