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


struct PlaylistModel: Codable {
    
    var json: Data? { try? JSONEncoder().encode(self) }

    init() {}
    init? (json: Data?) {
        if let json = json , let playList = try? JSONDecoder().decode(PlaylistModel.self, from: json) {
            self = playList
        } else {
            return nil
        }
    }
    
    private(set) var playList = [Podcast]()
    
    //MARK: - Methods
    mutating func removeFromPlayList(_ podcast: Podcast) {
        if let index = playList.firstIndex(matching: podcast) {
            playList.remove(at: index)
        }
//        MyActionSheet.create(title: movie.title + "\n" + Localized.successRemoveFromFavoriteList)
    }
    
    mutating func addToPlayList(_ podcast: Podcast) {
        playList.append(podcast)
//        MyToast.create(title: movie.title + "\n" + Localized.isAddToFavourite, .bottom)
    }
    
    mutating func removeAllFromPlaylist() {
        playList.removeAll()
//        MyActionSheet.create(title: Localized.allFavoritesMoviesDeleted)
//        UIApplication.shared.windows[0].rootViewController?.tabBarController?.selectedIndex = 0
    }

}
