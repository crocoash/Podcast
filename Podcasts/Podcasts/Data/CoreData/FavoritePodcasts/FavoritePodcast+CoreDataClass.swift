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
        
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: String(describing: Self.self), in: context)
        else { fatalError("mistake") }
        
        self.init(entity: entity, insertInto: nil)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        podcast = try values.decode(Podcast.self, forKey: .podcast)
        idd = try values.decode(String.self, forKey: .idd)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(podcast,forKey: .podcast)
        try container.encode(idd,forKey: .idd)
    }
    
    convenience init(podcast: Podcast) {
        let viewContext = DataStoreManager.shared.viewContext
        let newPodcast = Podcast.getOrCreatePodcast(podcast: podcast)

        guard let entity = NSEntityDescription.entity(forEntityName: "FavoritePodcast", in: viewContext) else { fatalError() }
        self.init(entity: entity, insertInto: viewContext)
        
        self.podcast = newPodcast
        self.idd = "=="
    }
}
