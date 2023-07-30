//
//  ListeningPodcast+CoreDataClass.swift
//  Podcasts
//
//  Created by Anton on 11.02.2023.
//
//

import Foundation
import CoreData

@objc(ListeningPodcast)
public class ListeningPodcast: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case currentTime
        case duration
        case progress
        case podcast
        case identifier
    }
    
    ///decoder
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        currentTime = try container.decode(Float.self, forKey: .currentTime)
        duration    = try container.decode(Double.self, forKey: .duration)
        progress    = try container.decode(Double.self, forKey: .progress)
        podcast     = try container.decode(Podcast.self, forKey: .podcast)
        identifier  = try container.decode(String.self, forKey: .identifier)
    }
    
    ///encode
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(currentTime, forKey: .currentTime)
        try container.encode(duration,    forKey: .duration)
        try container.encode(progress,    forKey: .progress)
        try container.encode(podcast,     forKey: .podcast)
        try container.encode(identifier,  forKey: .identifier)
    }
    
    ///init
    @discardableResult
    convenience init(_ podcast: Podcast, viewContext: NSManagedObjectContext, dataStoreManagerInput: DataStoreManagerInput) {
        
        self.init(entity: Self.entity(), insertInto: viewContext)
        
        self.podcast    = dataStoreManagerInput.getFromCoreDataIfNoSavedNew(entity: podcast)
        self.identifier = UUID().uuidString
        
        dataStoreManagerInput.mySave()
    }
    
    @discardableResult
    required convenience init(_ entity: ListeningPodcast, viewContext: NSManagedObjectContext?, dataStoreManagerInput: DataStoreManagerInput?) {
        
        self.init(entity: Self.entity(), insertInto: viewContext)
        
        self.currentTime = entity.currentTime
        self.duration    = entity.duration
        self.progress    = entity.progress
        self.podcast     = dataStoreManagerInput?.getFromCoreDataIfNoSavedNew(entity: entity.podcast) ?? entity.podcast
        self.identifier  = entity.identifier
        
        dataStoreManagerInput?.mySave()
    }
}

//MARK: - CoreDataProtocol
extension ListeningPodcast: CoreDataProtocol { }

//MARK: - FirebaseProtocol
extension ListeningPodcast: FirebaseProtocol { }

extension ListeningPodcast: ListeningPodcastCellProtocol {
    
    var podcastName: String? {
        podcast.trackName
    }
    
    var progressForCell: Float { return Float(progress) }
    var imageForCell: String? { return podcast.image600 }
}
