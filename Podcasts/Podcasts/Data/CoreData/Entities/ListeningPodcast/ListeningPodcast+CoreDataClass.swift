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
    convenience init(_ podcast: Podcast) {
        
        self.init(entity: Self.entity(), insertInto: Self.viewContext)
        
        self.podcast    = podcast.getFromCoreDataIfNoSavedNew
        self.identifier = UUID().uuidString
        
        mySave()
    }
    
    @discardableResult
    required convenience init(_ listeningPodcast: ListeningPodcast) {
        
        self.init(entity: Self.entity(), insertInto: Self.viewContext)
        
        self.currentTime = listeningPodcast.currentTime
        self.duration    = listeningPodcast.duration
        self.progress    = listeningPodcast.progress
        self.podcast     = listeningPodcast.podcast.getFromCoreDataIfNoSavedNew
        self.identifier  = listeningPodcast.identifier
    }
    
    @discardableResult
    required convenience init(_ listeningPodcast: ListeningPodcast, viewContext: NSManagedObjectContext) {
        
        self.init(entity: Self.entity(), insertInto: Self.viewContext)
        
        self.currentTime = listeningPodcast.currentTime
        self.duration    = listeningPodcast.duration
        self.progress    = listeningPodcast.progress
        self.podcast     = listeningPodcast.podcast.getFromCoreDataIfNoSavedNew
        self.identifier  = listeningPodcast.identifier
        
        mySave()
    }
    
    
}

//MARK: - CoreDataProtocol
extension ListeningPodcast: CoreDataProtocol { }

//MARK: - FirebaseProtocol
extension ListeningPodcast: FirebaseProtocol { }
