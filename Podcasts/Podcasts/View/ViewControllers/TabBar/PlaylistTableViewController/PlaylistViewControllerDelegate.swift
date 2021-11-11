//
//  PlaylistTableViewControllerDelegate.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 07.11.2021.
//

import Foundation

protocol PlaylistViewControllerDelegate : AnyObject {
    func playlistTableViewController(_ playlistTableViewController: PlaylistViewController, _ podcasts: [Podcast], didSelectIndex: Int)
}
