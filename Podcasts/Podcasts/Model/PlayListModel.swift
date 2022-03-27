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
        guard let stringUrl = podcast.previewUrl,
        let url = URL(string: stringUrl) else { return }
        
        do {
            try FileManager.default.removeItem(at: url.locaPath)
        }
        catch(let err) {
            print("FAILED DELETEING VIDEO DATA \(err.localizedDescription)")
        }
    }
    
    mutating func addToPlayList(_ podcast: Podcast) {
        playList.append(podcast)
    }
    
    mutating func trackIsDownloaded(index: Int) {
//        if let index = playList.firstIndex(matching: index) {
//            playList[index].isDownLoad = true
//        }
        
    }
    
    mutating func removeAllFromPlaylist() {
        playList.forEach {
            removeFromPlayList($0)
        }
    }
    
    mutating func podcastIsDownload(podcast: Podcast) -> Bool {
        if let index = playList.firstIndex(matching: podcast.id) {
            return playList[index].isDownLoad
        } else {
            return false
        }
    }
    
    mutating func podcastIsFavorite(podcast: Podcast) -> Bool {
        for i in playList {
            if i.id == podcast.id {
               return true
            }
        }
        return false
    }
    
    func isPodcastInPlaylist(_ podcast: Podcast) -> Bool {
        return playList.contains(podcast)
    }
}
