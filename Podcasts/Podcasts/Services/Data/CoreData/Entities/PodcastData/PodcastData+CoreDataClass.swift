//
//  PodcastData+CoreDataClass.swift
//  Podcasts
//
//  Created by Anton on 09.04.2022.
//
//

import Foundation
import CoreData


public class PodcastData: NSManagedObject, Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case resultCount, results
    }
    
    required convenience public init(from decoder: Decoder) throws {
        self.init(entity: Self.entity(), insertInto: nil)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        resultCount = try values.decode(Int32.self,        forKey: .resultCount)
        results =     try values.decode(Set<Podcast>.self, forKey: .results) as NSSet
    }
}