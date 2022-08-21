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
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else { fatalError("mistake")  }
        self.init(entity: Self.entity(), insertInto: context)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        resultCount = try values.decode(Int32.self, forKey: .resultCount)
        results = try values.decode(Set<Author>.self, forKey: .results) as NSSet
    }
}

//MARK: - static methods
extension AuthorData: SearchProtocol {
    
    static func cancellSearch() {
        
        if let authoreDatas = try? Self.viewContext.fetch(AuthorData.fetchRequest()) {
            authoreDatas.forEach { authoreData in
                authoreData.results.forEach { authors in
                    viewContext.delete(authors as! NSManagedObject)
                }
                Self.saveContext()
            }
        }
        Self.removeAll()
    }
}

