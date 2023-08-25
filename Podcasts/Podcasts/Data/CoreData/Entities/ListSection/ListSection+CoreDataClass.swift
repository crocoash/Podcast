//
//  ListSection+CoreDataClass.swift
//  Podcasts
//
//  Created by Anton on 07.08.2023.
//
//

import Foundation
import CoreData

@objc(ListSection)
public class ListSection: NSManagedObject, Decodable {

    private enum CodingKeys: String, CodingKey {
        case id, isActive, listData, nameOfEntity, nameOfSection, sequenceNumber
    }
    
    //MARK: decoder
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.isActive = try container.decode(Bool.self, forKey: .isActive)
        self.nameOfEntity = try container.decode(String.self, forKey: .nameOfEntity)
        self.nameOfSection = try container.decode(String.self, forKey: .nameOfSection)
        self.sequenceNumber = try container.decode(Int.self, forKey: .sequenceNumber) as NSNumber
    }
    
    //MARK: encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id,                       forKey: .id)
        try container.encodeIfPresent(isActive,                 forKey: .isActive)
        try container.encodeIfPresent(nameOfEntity,             forKey: .nameOfEntity)
        try container.encodeIfPresent(nameOfSection,            forKey: .nameOfSection)
        try container.encodeIfPresent(sequenceNumber.uintValue, forKey: .sequenceNumber)
    }
    
    //MARK: Init
    convenience init(entity: NSManagedObject.Type, nameOfSection: String, sequenceNumber: Int, viewContext: NSManagedObjectContext) {
        
        self.init(entity: Self.entity(), insertInto: viewContext)
        
        self.isActive = true
        self.nameOfEntity = entity.entityName
        self.nameOfSection = nameOfSection
        self.id = UUID().uuidString
        self.sequenceNumber = sequenceNumber as NSNumber
        self.listData = listData
    }
}

extension ListSection: CoreDataProtocol {
    
    static var defaultSortDescription: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(ListSection.nameOfEntity), ascending: true)]
    }
}


