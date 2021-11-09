//
//  DetailViewControllerDelegate.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 07.11.2021.
//

import Foundation

protocol DetailViewControllerDelegate: AnyObject {
    func detailViewController(_ detailViewController: DetailViewController, playButtonDidTouchFor didSelectIndex: Int)
}
