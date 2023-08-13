//
//  ListData+CoreDataClass.swift
//  Podcasts
//
//  Created by Anton on 08.08.2023.
//
//

import Foundation
import CoreData

@objc(ListData)
public class ListData: NSManagedObject {

    private enum CodingKeys: String, CodingKey {
            case id, listSection
    }
    
    //MARK: decoder
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id =            try container.decode(String.self, forKey: .id)
        self.listSection =   try container.decode(ListSection.self, forKey: .listSection)
    }
    
    //MARK: encode
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id,           forKey: .id)
        try container.encode(listSection,  forKey: .listSection)
    }
        
        
    required convenience init(_ entity: ListData, viewContext: NSManagedObjectContext, dataStoreManagerInput: DataStoreManagerInput) {
        self.init(entity: Self.entity(), insertInto: viewContext)
        
        self.id = entity.id
        self.listSection = dataStoreManagerInput.getFromCoreDataIfNoSavedNew(entity: entity.listSection)
        
    }
}

//MARK: - CoreDataProtocol
extension ListData: CoreDataProtocol {
    
    static var defaultSortDescription: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(ListData.listSection), ascending: true)]
    }
}
