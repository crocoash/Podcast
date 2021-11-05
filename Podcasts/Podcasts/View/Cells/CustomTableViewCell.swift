//
//  CustomTableViewCell.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 04.11.2021.
//

import UIKit

// FIXME: Зачем это нужно? Ячейка не должна хранить свой индекс пас. Избавиться

protocol CustomTableViewCell: UITableViewCell {
    var indexPath: IndexPath! { get }
}
