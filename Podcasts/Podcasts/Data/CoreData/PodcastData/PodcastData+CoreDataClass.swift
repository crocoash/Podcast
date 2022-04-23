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
        
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            fatalError("mistake")
        }
        
        let entity = NSEntityDescription.entity(forEntityName: "PodcastData", in: context)!
        
        self.init(entity: entity, insertInto: context)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        resultCount = try values.decode(Int32.self, forKey: .resultCount)
        results = try values.decode(Set<Podcast>.self, forKey: .results) as NSSet
    }
}

//MARK: - static methods
extension PodcastData: SearchProtocol {

    static let viewContext = DataStoreManager.shared.viewContext
    
    static func cancellSearch() {
        if let podcastData = try? viewContext.fetch(PodcastData.fetchRequest()) {
            podcastData.forEach { podcasts in
                podcasts.results.forEach { podcast in
                    if let podcast = podcast as? Podcast {
                        if podcast.isFavorite {
                            podcast.isSearched = false
                        } else {
                            viewContext.delete(podcast)
                        }
                    }
                }
                DataStoreManager.shared.mySave()
            }
        }
        
        if let podcasts = try? DataStoreManager.shared.viewContext.fetch(Podcast.fetchRequest()) {
            podcasts.forEach {
                if !$0.isFavorite {
                    viewContext.delete($0)
                } else {
                    $0.isSearched = false
                }
            }
            DataStoreManager.shared.mySave()
        }
        
        DataStoreManager.shared.removeAll(fetchRequest: PodcastData.fetchRequest())
    }
}
