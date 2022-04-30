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
        case podcastID
    }
    
    required convenience public init(from decoder: Decoder) throws {

        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "LikedMoment", in: context)
        else { fatalError("mistake") }

        self.init(entity: entity, insertInto: nil)
        let values = try decoder.container(keyedBy: CodingKeys.self)

        moment =    try values.decode(Double .self,  forKey: .moment)
        podcast =   try values.decode(Podcast.self,  forKey: .podcast)
        podcastID = try values.decode(Int.self,      forKey: .podcastID) as NSNumber
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(moment,              forKey: .moment)
        try container.encode(podcast,             forKey: .podcast)
        try container.encode(podcastID?.intValue, forKey: .podcastID)
    }
    
    convenience init(podcast: Podcast, moment: Double, id: NSNumber) {
        let viewContext = DataStoreManager.shared.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "LikedMoment", in: viewContext) else { fatalError() }
        self.init(entity: entity, insertInto: viewContext)
        
        self.moment = moment
        self.podcast = podcast
        self.podcastID = id
    }
}
