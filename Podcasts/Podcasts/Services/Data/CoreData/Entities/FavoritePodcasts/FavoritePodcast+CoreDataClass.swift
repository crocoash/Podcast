//
//  FavoritePodcast+CoreDataClass.swift
//  Podcasts
//
//  Created by Anton on 03.05.2022.
//
//

import Foundation
import CoreData


public class FavoritePodcast: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case podcast
        case idd
    }
    
    required convenience public init(from decoder: Decoder) throws {
        self.init(entity: Self.entity(), insertInto: nil)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        podcast = try values.decode(Podcast.self, forKey: .podcast)
        idd = try values.decode(String.self, forKey: .idd)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(podcast,forKey: .podcast)
        try container.encode(idd,forKey: .idd)
    }
    
    convenience init(podcast: Podcast, date: String) {
        let newPodcast = Podcast.getOrCreatePodcast(podcast: podcast)

        self.init(entity: Self.entity(), insertInto: Self.viewContext)
        
        self.podcast = newPodcast
        self.idd = date
    }
}

extension FavoritePodcast {
    
    static func getOrCreateFavoritePodcast(_ favoritePodcast: FavoritePodcast) -> FavoritePodcast {
        if let favoritePodcasts = try? viewContext.fetch(FavoritePodcast.fetchRequest()) {
            for favoritePodcast in favoritePodcasts {
                if favoritePodcast.podcast.id == favoritePodcast.podcast.id {
                    return favoritePodcast
                }
            }
        }
        let podcast = Podcast.getOrCreatePodcast(podcast: favoritePodcast.podcast)
        return FavoritePodcast(podcast: podcast, date: favoritePodcast.idd)
    }
}
