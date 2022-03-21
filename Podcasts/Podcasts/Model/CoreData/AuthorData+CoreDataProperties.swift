//
//  AuthorData+CoreDataProperties.swift
//  
//
//  Created by Tsvetkov Anton on 20.03.2022.
//
//

import Foundation
import CoreData

extension AuthorData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthorData> {
        return NSFetchRequest<AuthorData>(entityName: "AuthorData")
    }

    @NSManaged public var resultCount: Int32
    @NSManaged public var results: NSSet
}

// MARK: Generated accessors for results
extension AuthorData {

    @objc(addResultsObject:)
    @NSManaged public func addToResults(_ value: AuthorData)

    @objc(removeResultsObject:)
    @NSManaged public func removeFromResults(_ value: AuthorData)

    @objc(addResults:)
    @NSManaged public func addToResults(_ values: NSSet)

    @objc(removeResults:)
    @NSManaged public func removeFromResults(_ values: NSSet)

}


extension AuthorData: SaveContextProtocol {
    
    static func save<T>(with value: T) {
        
        guard let value = value as? AuthorData else { fatalError() }
        
        let authorData = AuthorData(context: DataStoreManager.shared.viewContext)
        
        authorData.resultCount = value.resultCount
        authorData.results = value.results
        
        DataStoreManager.shared.saveContext()
    }
}
