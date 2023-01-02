//
//  AuthorData+CoreDataProperties.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 02.04.2022.
//
//

import Foundation
import CoreData

extension AuthorData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthorData> {
        return NSFetchRequest<AuthorData>(entityName: Self.entityName)
    }

    @NSManaged public var resultCount: Int32
    @NSManaged public var results: NSSet

}

// MARK: Generated accessors for results
extension AuthorData {

    @objc(addResultsObject:)
    @NSManaged public func addToResults(_ value: Author)

    @objc(removeResultsObject:)
    @NSManaged public func removeFromResults(_ value: Author)

    @objc(addResults:)
    @NSManaged public func addToResults(_ values: NSSet)

    @objc(removeResults:)
    @NSManaged public func removeFromResults(_ values: NSSet)

}

