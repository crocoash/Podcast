//
//  Constant.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 04.11.2021.
//

import Foundation

enum UrlRequest1 {
    
    case podcastEpisode(String)
    case authors(String)
    case podcastById(String)
    
    var url: String {
        switch self {
        case .podcastEpisode(let string):
            return "https://itunes.apple.com/search?term=\(string)&entity=podcastEpisode&limit=200"
        case .authors(let string):
            return "https://itunes.apple.com/search?term=\(string)&media=podcast&entity=podcastAuthor"
        case .podcastById(let string):
            return "https://itunes.apple.com/lookup?id=\(string)&media=podcast&entity=podcastEpisode&limit=8"
        }
    }
}

//TODO: change name
enum URLS: String {
    case api = "http://ip-api.com/json/"
}
