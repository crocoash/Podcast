//
//  ListeningManager.swift
//  Podcasts
//
//  Created by Anton on 24.07.2023.
//

import Foundation


protocol InputListeningManager {
    var podcast: Podcast { get }
}

class ListeningManager {
    
    private var dataStoreManagerInput: DataStoreManagerInput
    
    init(dataStoreManagerInput: DataStoreManagerInput) {
        self.dataStoreManagerInput = dataStoreManagerInput
    }
    
    func saveListeningProgress(for entity: (any InputListeningManager), progress: Double) {
        
        let listeningPodcasts = dataStoreManagerInput.allObjectsFromCoreData(type: ListeningPodcast.self)
        let listeningPodcast = listeningPodcasts.filter { $0.podcast.identifier == entity.podcast.identifier }.first
        
        if let listeningPodcast = listeningPodcast {
            listeningPodcast.progress = progress
        } else {
            _ = ListeningPodcast.init(entity.podcast, viewContext: dataStoreManagerInput.viewContext, dataStoreManagerInput: dataStoreManagerInput)
        }
        dataStoreManagerInput.mySave()
    }
}
