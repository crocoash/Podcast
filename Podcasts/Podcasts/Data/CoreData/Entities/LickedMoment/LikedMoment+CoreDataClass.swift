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
        case identifier
    }
    
    //MARK: decoder
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        moment =     try values.decode(Double .self, forKey: .moment)
        podcast =    try values.decode(Podcast.self, forKey: .podcast)
        identifier = try values.decode(String.self , forKey: .identifier)
    }
    
    //MARK: encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(moment,     forKey: .moment)
        try container.encode(podcast,    forKey: .podcast)
        try container.encode(identifier, forKey: .identifier)
    }
    
    //MARK: init
    
    @discardableResult
    convenience init(podcast: Podcast, moment: Double, viewContext: NSManagedObjectContext?, dataStoreManagerInput: DataStoreManagerInput?) {
        
        self.init(entity: Self.entity(), insertInto: viewContext)
        
        self.moment     = moment
        self.podcast    = dataStoreManagerInput?.getFromCoreDataIfNoSavedNew(entity: podcast) ?? podcast
        self.identifier = UUID().uuidString
        
        dataStoreManagerInput?.mySave()
    }
    
    @discardableResult
    required convenience init(_ likedMoment: LikedMoment, viewContext: NSManagedObjectContext?, dataStoreManagerInput: DataStoreManagerInput?) {
        
        self.init(entity: Self.entity(), insertInto: viewContext)
        
        self.moment     = likedMoment.moment
        self.podcast    = likedMoment.podcast
        self.identifier = likedMoment.identifier
        
        dataStoreManagerInput?.mySave()
    }
}


//MARK: - CoreDataProtocol
extension LikedMoment: CoreDataProtocol { }

//MARK: - FirebaseProtocol
extension LikedMoment: FirebaseProtocol { }
