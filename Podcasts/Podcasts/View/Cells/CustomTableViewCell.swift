//
//  CustomTableViewCell.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 04.11.2021.
//

import UIKit

protocol CustomTableViewCell: UITableViewCell {
    var indexPath: IndexPath! { get }
}
