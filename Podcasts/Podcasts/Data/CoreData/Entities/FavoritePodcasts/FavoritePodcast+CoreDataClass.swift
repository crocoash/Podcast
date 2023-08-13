//
//  FavoritePodcast+CoreDataClass.swift
//  Podcasts
//
//  Created by Anton on 03.05.2022.
//
//

import UIKit
import CoreData

public class FavoritePodcast: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case podcast
        case date
        case id
    }
    
    //MARK: decoder
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.podcast = try values.decode(Podcast.self, forKey: .podcast)
        self.date = try values.decode(Date.self, forKey: .date)
        self.id = try values.decode(String.self, forKey: .id)
    }
    
    //MARK: encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(podcast, forKey: .podcast)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(id, forKey: .id)
    }
    
    @discardableResult
    convenience init(_ entity: Podcast, viewContext: NSManagedObjectContext, dataStoreManager: DataStoreManagerInput) {
            
       self.init(entity: Self.entity(), insertInto: viewContext)
        
        self.date = Date()
        self.podcast = dataStoreManager.getFromCoreDataIfNoSavedNew(entity: entity)
        self.id = UUID().uuidString
    }
}

//MARK: - CoreDataProtocol
extension FavoritePodcast: CoreDataProtocol {
   
    static var defaultSortDescription: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(FavoritePodcast.date), ascending: true)]
    }
}

//MARK: - FirebaseProtocol
extension FavoritePodcast: FirebaseProtocol { }

//MARK: - InputPodcastCell
extension FavoritePodcast: InputPodcastCell {
    
    var inputPodcastCell: PodcastCellProtocol {
        return podcast
    }
}

//MARK: - InputDownloadProtocol
extension FavoritePodcast: InputDownloadProtocol {
    
    var downloadEntity: DownloadProtocol {
        return podcast
    }
}


