//
//  LikedMoment+CoreDataClass.swift
//  Podcasts
//
//  Created by Anton on 15.04.2022.
//
//

import Foundation
import CoreData


public class LikedMoment: NSManagedObject, Decodable {

    private enum CodingKeys: String, CodingKey {
        case moment, podcast
    }
    
    required convenience public init(from decoder: Decoder) throws {
        
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            fatalError("mistake")
        }
        
        let entity = NSEntityDescription.entity(forEntityName: "AuthorData", in: context)!
        
        self.init(entity: entity, insertInto: context)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        moment = try values.decode(Double.self, forKey: .moment)
        podcast = try values.decode(Podcast.self, forKey: .podcast) 
    }
}
