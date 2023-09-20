//
//  Constant.swift
//  Podcasts
//https://itunes.apple.com/lookup?id=-2854&entity=album
//  Created by Tsvetkov Anton on 04.11.2021.
//

import Foundation

enum DynamicLinkManager {
    
    case podcastSearch(String)
    case authors(String)
    case podcastEpisodeById(String)
    
    var url: String {
        switch self {
        case .podcastSearch(let string):
            return "https://itunes.apple.com/search?term=\(string)&entity=podcastEpisode"
        case .authors(let string):
            return "https://itunes.apple.com/search?term=\(string)&media=podcast&entity=podcastAuthor"
        case .podcastEpisodeById(let string):
            return "https://itunes.apple.com/lookup?id=\(string)&entity=podcastEpisode"
        }
//    https://itunes.apple.com/lookup?id=411682463&entity=podcast ++ collection id ( 1 track )
//    https://itunes.apple.com/lookup?id=411682463&entity=podcastEpisode + ++ collection id ( 1 episode )
//    https://itunes.apple.com/search?term=1000014283264&entity=podcast
    }
}
//TODO: change name
enum URLS: String {
    case api = "http://ip-api.com/json/"
}
