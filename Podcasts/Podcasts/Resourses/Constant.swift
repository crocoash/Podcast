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
    case podcastEpisodeByCollectionId(Int)
    case podcastByAuthorId(Int)
    case topPodcast
    
    var url: String {
        return switch self {
        case .topPodcast:
            "https://itunes.apple.com/us/rss/toppodcasts/limit=10/genre=1318/json"
            
        case .podcastSearch(let string):
             "https://itunes.apple.com/search?term=\(string)&entity=podcast&limit=200" // Episode
//            "https://api.ios-app-developer.com/podcasts/search?term=\(string)"
            
        case .authors(let string):
             "https://itunes.apple.com/search?term=\(string)&entity=podcastAuthor&media=podcast"
            
        case .podcastEpisodeByCollectionId(let id):
             "https://itunes.apple.com/lookup?id=\(id)&entity=podcastEpisode"
        
        case .podcastByAuthorId(let id):
          "https://itunes.apple.com/lookup?id=\(id)&media=podcast&entity=podcast"
        }
    }
}
//TODO: change name
enum URLS: String {
    case api = "http://ip-api.com/json/"
}
