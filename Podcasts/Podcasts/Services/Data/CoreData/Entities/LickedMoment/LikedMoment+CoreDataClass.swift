//
//  LikedMoment+CoreDataClass.swift
//  Podcasts
//
//  Created by Anton on 15.04.2022.
//
//

import Foundation
import CoreData


public class LikedMoment: NSManagedObject, Codable {
        
    private enum CodingKeys: String, CodingKey {
        case moment
        case podcast
    }
    
    required convenience public init(from decoder: Decoder) throws {

        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: String(describing: Self.self), in: context)
        else { fatalError("mistake") }

        self.init(entity: entity, insertInto: nil)
        let values = try decoder.container(keyedBy: CodingKeys.self)

        moment =    try values.decode(Double .self, forKey: .moment)
        podcast =   try values.decode(Podcast.self, forKey: .podcast)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(moment,              forKey: .moment)
        try container.encode(podcast,             forKey: .podcast)
    }
    
    convenience init(podcast: Podcast, moment: Double) {
        let newPodcast = Podcast.getOrCreatePodcast(podcast: podcast)
     
        self.init(entity: Self.entity(), insertInto: Self.viewContext)
                
        self.moment = moment
        self.podcast = newPodcast
    }
}

