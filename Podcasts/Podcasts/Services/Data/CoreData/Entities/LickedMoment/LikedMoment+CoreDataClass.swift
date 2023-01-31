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
    
    ///decoder
    required convenience public init(from decoder: Decoder) throws {

        self.init(entity: Self.entity(), insertInto: nil)
        let values = try decoder.container(keyedBy: CodingKeys.self)

        moment =    try values.decode(Double .self, forKey: .moment)
        podcast =   try values.decode(Podcast.self, forKey: .podcast)
    }
    
    ///encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(moment, forKey: .moment)
        try container.encode(podcast,forKey: .podcast)
    }
    
    ///init
    convenience init(newPodcast: Podcast, moment: Double) {
        let podcast = Podcast.getOrCreatePodcast(podcast: newPodcast)
        
        self.init(entity: Self.entity(), insertInto: Self.viewContext)
                
        self.moment = moment
        self.podcast = podcast
        
        Self.viewContext.mySave()
    }
}



