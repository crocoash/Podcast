//
//  PodacstData.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 25.10.2021.
//

import Foundation

struct PodcastData: Codable {
    let resultCount: Int
    let results: [Podcast]
}
