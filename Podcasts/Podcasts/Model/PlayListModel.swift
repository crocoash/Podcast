//
//  PlayListModel.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 01.11.2021.
//

import Foundation

struct PlaylistModel: Codable {
    
    var json: Data? { try? JSONEncoder().encode(self) }
    
    private(set) var playList: [Podcast]

    init() {
        playList = []
    }
    
    init? (json: Data?) {
        guard
            let json = json ,
            let playList = try? JSONDecoder().decode(PlaylistModel.self, from: json)
        else { return nil }
        
        self = playList
    }
    
    
    //MARK: - Methods
    mutating func removeFromPlayList(_ podcast: Podcast) {
        if let index = playList.firstIndex(matching: podcast) {
            playList.remove(at: index)
        }
    }
    
    mutating func addToPlayList(_ podcast: Podcast) {
        playList.append(podcast)
    }
    
    mutating func trackIsDownloaded(index: Int) {
        if let index = playList.firstIndex(matching: index) {
            playList[index].isDownLoad = true
        }
    }
    
    mutating func removeAllFromPlaylist() {
        playList.removeAll()
    }
    
    mutating func podcastIsDownload(podcast: Podcast) -> Bool {
        if let index = playList.firstIndex(matching: podcast.id) {
            return playList[index].isDownLoad
        } else {
            return true
        }
    }
    
    func isPodcastInPlaylist(_ podcast: Podcast) -> Bool {
        
        return false
    }

}
