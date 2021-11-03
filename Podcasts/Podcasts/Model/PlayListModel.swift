//
//  PlayListModel.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 01.11.2021.
//

import Foundation

struct PlaylistModel: Codable {
    
    var json: Data? { try? JSONEncoder().encode(self) }
    
    init() {}
    init? (json: Data?) {
        guard
            let json = json ,
            let playList = try? JSONDecoder().decode(PlaylistModel.self, from: json)
        else { return nil }
        
        self = playList
    }
    
    private(set) var playList = [Podcast]()
    
    //MARK: - Methods
    mutating func removeFromPlayList(_ podcast: Podcast) {
        if let index = playList.firstIndex(matching: podcast) {
            playList.remove(at: index)
        }
    }
    
    mutating func addToPlayList(_ podcast: Podcast) {
        playList.append(podcast)
        
    }
    
    mutating func removeAllFromPlaylist() {
        playList.removeAll()
    }

}
