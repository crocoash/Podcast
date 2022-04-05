//
//  AuthorData+CoreDataClass.swift
//
//
//  Created by Tsvetkov Anton on 20.03.2022.
//
//

import Foundation
import CoreData

public class AuthorData: NSManagedObject, Decodable {

    private enum CodingKeys: String, CodingKey {
        case resultCount, results
    }
    
    required convenience public init(from decoder: Decoder) throws {
        
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            fatalError("mistake")
        }
        
        let entity = NSEntityDescription.entity(forEntityName: "AuthorData", in: context)!
        
        self.init(entity: entity, insertInto: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        resultCount = try container.decode(Int32.self, forKey: .resultCount)
        results = try container.decode(Set<Author>.self, forKey: .results) as NSSet
    }
}

//MARK: - static methods
extension AuthorData {
    
    static func removeAll() {
        
        let fetchRequest =  AuthorData.fetchRequest()
        let dataStoreManager = DataStoreManager.shared

        if let data = try? dataStoreManager.viewContext.fetch(fetchRequest), !data.isEmpty {
            data.forEach { x in
                dataStoreManager.viewContext.delete(x)
                try? dataStoreManager.viewContext.save()
            }
        }
    }
}
