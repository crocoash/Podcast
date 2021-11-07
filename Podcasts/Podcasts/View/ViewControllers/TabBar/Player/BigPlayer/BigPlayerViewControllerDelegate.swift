//
//  BigPlayerViewControllerDelegate.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 07.11.2021.
//

import Foundation

protocol BigPlayerViewControllerDelegate: AnyObject {
    
    func bigPlayerViewControllerDidSelectStopButton (_ bigPlayerViewController: BigPlayerViewController)
    func bigPlayerViewControllerDidSelectNextTrackButton (_ bigPlayerViewController: BigPlayerViewController)
    func bigPlayerViewControllerDidSelectPreviewsTrackButton (_ bigPlayerViewController: BigPlayerViewController)
    func bigPlayerViewController (_ bigPlayerViewController: BigPlayerViewController, didChangeCurrentTime  value: Double)
    func bigPlayerViewController (_ bigPlayerViewController: BigPlayerViewController, didAddCurrentTimeBy value: Double)
    
}
