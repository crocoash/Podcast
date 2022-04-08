//
//  PodcastData.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 25.10.2021.
//

import Foundation

struct PodcastData: Decodable {
    let resultCount: Int
    let results: [Podcast]
}

extension PodcastData: SearchProtocol {
    static func removeAll() {
        
    }
    
    static func newSearch() {
        Podcast.newSearch()
    }
}
