//
//  LikedMomentsViewControllerDelegate.swift
//  Podcasts
//
//  Created by mac on 08.11.2021.
//

import Foundation

protocol LikedMomentsViewControllerDelegate: AnyObject {
    func likedMomentsViewController(_ likedMomentsViewController: LikedMomentsViewController, _ didSelectMoment: LikedMoment)
}
