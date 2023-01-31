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
        let podcast = Podcast.getOrCreatePodcast(podcast: podcast)

        self.init(entity: Self.entity(), insertInto: Self.viewContext)
        
        self.podcast = podcast
        self.idd = date
        
        Self.viewContext.mySave()
    }
}
