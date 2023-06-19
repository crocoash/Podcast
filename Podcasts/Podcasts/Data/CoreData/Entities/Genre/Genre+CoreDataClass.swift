//
//  Genre+CoreDataClass.swift
//  Podcasts
//
//  Created by Anton on 13.02.2023.
//
//

import Foundation
import CoreData

@objc(Genre)
public class Genre: NSManagedObject, Codable {
    private enum CodingKeys: String, CodingKey {
        case identifier, name
    }
    
    //MARK: decoder
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        identifier = try container.decodeIfPresent(String.self, forKey: .identifier) ?? UUID().uuidString
        name = try container.decodeIfPresent(String.self, forKey: .name)
        
    }
    
    //MARK: encode
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(identifier, forKey: .identifier)
        try container.encode(name,forKey: .name)
    }
    
    //MARK: init

    convenience init(identifier: String, name: String?, viewContext: NSManagedObjectContext? = viewContext) {
        
        self.init(entity: Self.entity(), insertInto: viewContext)
        
        self.identifier = identifier
        self.name = name
        
        if viewContext != nil {
            mySave()
        }
    }
    
    /// to viewContext
    required convenience init(_ genre: Genre) {
        
        self.init(entity: Self.entity(), insertInto: Self.viewContext)
        self.identifier = genre.identifier
        
        self.name = genre.name
        self.podcasts = genre.podcasts
    }
}

//MARK: - CoreDataProtocol
extension Genre: CoreDataProtocol { }

