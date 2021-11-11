//
//  UITableView + register.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 30.10.2021.
//

import UIKit

extension UITableView {
    func register(_ cell: UITableViewCell.Type) {
        register(UINib(nibName: "\(cell)", bundle: nil), forCellReuseIdentifier: "\(cell)")
    }
    
    static var identifier: String {
        return "\(Self.self)"
    }
}
