//
//  User.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 03.11.2021.
//

import Foundation

struct User: Codable {
    var userName: String
    var userId: String
    var isAuthorization: Bool = false
    var userInterfaceStyleIsDark = true
}

