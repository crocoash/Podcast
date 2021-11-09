//
//  SettingsTableViewControllerDelegate.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 07.11.2021.
//

import Foundation

protocol SettingsTableViewControllerDelegate: AnyObject {
    func settingsTableViewControllerDidApear(_ settingsTableViewController: SettingsTableViewController)
    func settingsTableViewControllerDidDisapear(_ settingsTableViewController: SettingsTableViewController)
}
