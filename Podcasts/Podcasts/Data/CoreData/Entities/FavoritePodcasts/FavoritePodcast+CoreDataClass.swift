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
        case identifier
    }
    
    //MARK: decoder
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.podcast = try values.decode(Podcast.self, forKey: .podcast)
        self.date = try values.decode(Date.self, forKey: .date)
        self.identifier = try values.decode(String.self, forKey: .identifier)
    }
    
    //MARK: encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(podcast, forKey: .podcast)
        try container.encode(date, forKey: .date)
        try container.encode(identifier, forKey: .identifier)
    }
    
    @discardableResult
    required convenience init(_ entity: Podcast, viewContext: NSManagedObjectContext?, dataStoreManagerInput: DataStoreManagerInput?) {
            
       self.init(entity: Self.entity(), insertInto: viewContext)
        
        self.date = Date()
        self.podcast = dataStoreManagerInput?.getFromCoreDataIfNoSavedNew(entity: entity) ?? entity
        self.identifier = UUID().uuidString
        
        dataStoreManagerInput?.mySave()
    }
    
    required convenience init(_ entity: FavoritePodcast, viewContext: NSManagedObjectContext?, dataStoreManagerInput: DataStoreManagerInput?) {
            
        self.init(entity: Self.entity(), insertInto: viewContext)
        
        self.date = Date()
        self.podcast = dataStoreManagerInput?.getFromCoreDataIfNoSavedNew(entity: entity.podcast) ?? entity.podcast
        self.identifier = UUID().uuidString
        
        dataStoreManagerInput?.mySave()
    }
}

//MARK: - CoreDataProtocol
extension FavoritePodcast: CoreDataProtocol { }

//MARK: - FirebaseProtocol
extension FavoritePodcast: FirebaseProtocol { }

//MARK: - InputFavoriteType
extension FavoritePodcast: InputFavoriteType {
    
    var favoriteInputTypeIdentifier: String {
        return podcast.identifier
    }
}

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

//MARK: - InputTrackProtocol
extension FavoritePodcast: InputTrackType {
    
    var track: TrackProtocol {
        return podcast
    }
}

//MARK: - InputListeningManager
extension FavoritePodcast: InputListeningManager {
    
}
