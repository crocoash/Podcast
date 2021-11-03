//
//  PodcastViewModel.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 30.10.2021.
//

import Foundation

class MyPlaylistDocument: Codable {
    
    private static var playlistKey = "playlistKey"
    
    static var shared = PlaylistModel(
        json: UserDefaults.standard.data(forKey: playlistKey)
    ) ?? PlaylistModel()  {
        didSet {
            UserDefaults.standard.setValue(MyPlaylistDocument.shared.json, forKey: playlistKey)
        }
    }
}
