//
//  LikedMomentsViewControllerDelegate.swift
//  Podcasts
//
//  Created by mac on 08.11.2021.
//

import Foundation

protocol LikedMomentsViewControllerDelegate: AnyObject {
    func likedMomentViewController(_ likedMomentViewController: LikedMomentsViewController, didSelect moment: LikedMoment)
}
