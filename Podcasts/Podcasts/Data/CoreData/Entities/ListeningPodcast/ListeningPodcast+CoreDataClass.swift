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
        case id
    }
    
    ///decoder
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        currentTime = try container.decode(Float.self, forKey: .currentTime)
        duration    = try container.decode(Double.self, forKey: .duration)
        progress    = try container.decode(Double.self, forKey: .progress)
        podcast     = try container.decode(Podcast.self, forKey: .podcast)
        id  = try container.decode(String.self, forKey: .id)
    }
    
    ///encode
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(currentTime, forKey: .currentTime)
        try container.encodeIfPresent(duration,    forKey: .duration)
        try container.encodeIfPresent(progress,    forKey: .progress)
        try container.encodeIfPresent(podcast,     forKey: .podcast)
        try container.encodeIfPresent(id,  forKey: .id)
    }
    
    ///init
    @discardableResult
    convenience init(_ podcast: Podcast, viewContext: NSManagedObjectContext, dataStoreManagerInput: DataStoreManagerInput) {
        
        self.init(entity: Self.entity(), insertInto: viewContext)
        
        self.podcast = dataStoreManagerInput.getFromCoreDataIfNoSavedNew(entity: podcast)
        self.id = UUID().uuidString
        
        dataStoreManagerInput.save()
    }
}

//MARK: - CoreDataProtocol
extension ListeningPodcast: CoreDataProtocol {
    
    static var defaultSortDescription: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(ListeningPodcast.currentTime),ascending: true)]
    }
}

//MARK: - FirebaseProtocol
extension ListeningPodcast: FirebaseProtocol {}

