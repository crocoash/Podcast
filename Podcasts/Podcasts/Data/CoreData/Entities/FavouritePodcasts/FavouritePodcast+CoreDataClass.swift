//
//  FavouritePodcast+CoreDataClass.swift
//  Podcasts
//
//  Created by Anton on 03.05.2022.
//
//

import UIKit
import CoreData

public class FavouritePodcast: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case podcast
        case dateAdd
        case id
    }
    
    //MARK: decoder
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.podcast = try values.decode(Podcast.self, forKey: .podcast)
        self.dateAdd = try values.decode(Date.self, forKey: .dateAdd)
        self.id = try values.decode(String.self, forKey: .id)
    }
    
    //MARK: encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(podcast, forKey: .podcast)
        try container.encodeIfPresent(dateAdd, forKey: .dateAdd)
        try container.encodeIfPresent(id, forKey: .id)
    }
    
    @discardableResult
    convenience init(_ entity: Podcast, viewContext: NSManagedObjectContext, dataStoreManager: DataStoreManagerInput) {
            
       self.init(entity: Self.entity(), insertInto: viewContext)
        
        self.dateAdd = Date()
        self.podcast = dataStoreManager.getFromCoreDataIfNoSavedNew(entity: entity)
        self.id = UUID().uuidString
    }
}

//MARK: - CoreDataProtocol
extension FavouritePodcast: CoreDataProtocol {
   
    static var defaultSortDescription: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(FavouritePodcast.dateAdd), ascending: true)]
    }
}

//MARK: - FirebaseProtocol
extension FavouritePodcast: FirebaseProtocol { }



//MARK: - InputDownloadProtocol
extension FavouritePodcast: InputDownloadProtocol {
    
    var downloadEntity: DownloadProtocol {
        return podcast
    }
}


