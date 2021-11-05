//
//  PlaylistDocument.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 30.10.2021.
//

import Foundation

class PlaylistDocument: Codable {
    
    private static var playlistKey = "playlistKey"
    
    static var shared = PlaylistModel(
        json: UserDefaults.standard.data(forKey: playlistKey)
    ) ?? PlaylistModel()  {
        didSet {
            // FIXME:
            UserDefaults.standard.setValue(PlaylistDocument.shared.json, forKey: playlistKey)
        }
    }
}

