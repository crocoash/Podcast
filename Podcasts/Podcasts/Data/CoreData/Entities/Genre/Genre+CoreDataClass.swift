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
        case id, name
    }
    
    //MARK: decoder
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        name = try container.decodeIfPresent(String.self, forKey: .name)
        
    }
    
    //MARK: encode
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(name,       forKey: .name)
    }
    
    //MARK: init
    convenience init(id: String, name: String?, viewContext: NSManagedObjectContext? = nil, dataStoreManagerInput: DataStoreManagerInput? = nil) {
        
        self.init(entity: Self.entity(), insertInto: viewContext)
        
        self.id = id
        self.name = name
        
        dataStoreManagerInput?.save()
    }
}

//MARK: - CoreDataProtocol
extension Genre: CoreDataProtocol {
    static var defaultSortDescription: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(Genre.name), ascending: true)]
    }
}

