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
        case id
    }
    
    //MARK: decoder
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        moment =     try values.decode(Double .self, forKey: .moment)
        podcast =    try values.decode(Podcast.self, forKey: .podcast)
        id = try values.decode(String.self , forKey: .id)
    }
    
    //MARK: encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(moment,     forKey: .moment)
        try container.encodeIfPresent(podcast,    forKey: .podcast)
        try container.encodeIfPresent(id, forKey: .id)
    }
    
    //MARK: init
    
    @discardableResult
    convenience init(podcast: Podcast, moment: Double, viewContext: NSManagedObjectContext?, dataStoreManagerInput: DataStoreManagerInput) {
        
        self.init(entity: Self.entity(), insertInto: viewContext)
        
        self.moment     = moment
        self.podcast    = dataStoreManagerInput.getFromCoreDataIfNoSavedNew(entity: podcast)
        self.id = UUID().uuidString
        
        dataStoreManagerInput.save()
    }
}


//MARK: - CoreDataProtocol
extension LikedMoment: CoreDataProtocol {
    
    static var defaultSortDescription: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(LikedMoment.moment), ascending: true)]
    }
}

//MARK: - FirebaseProtocol
extension LikedMoment: FirebaseProtocol { }
