//
//  AuthorData.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 31.10.2021.
//

import Foundation

struct AuthorData: Codable {
    let resultCount: Int
    let results: [Author]
}
