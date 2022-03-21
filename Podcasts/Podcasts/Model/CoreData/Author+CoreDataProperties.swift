//
//  Author+CoreDataProperties.swift
//  
//
//  Created by Tsvetkov Anton on 19.03.2022.
//
//

import Foundation
import CoreData


extension Author {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Author> {
        return NSFetchRequest<Author>(entityName: "Author")
    }

    @NSManaged public var artistType: String?
    @NSManaged public var artistName: String?
    @NSManaged public var artistLinkURL: String?
    @NSManaged public var artistID: Int32
}

extension Author: SaveContextProtocol {
    static func save<T>(with value: T) {
        
        guard let value = value as? Author else { fatalError() }
        
    
        let author = Author(context: DataStoreManager.shared.viewContext)
        
        author.artistID = value.artistID
        author.artistLinkURL = value.artistLinkURL
        author.artistName = value.artistName
        author.artistType = value.artistType
        
        DataStoreManager.shared.saveContext()
    }
    
    static func save<T>(with values: [T]) {
        values.forEach {
            save(with: $0)
        }
    }
}


