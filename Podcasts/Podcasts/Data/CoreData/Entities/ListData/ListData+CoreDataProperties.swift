//
//  ListData+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 22.08.2023.
//
//

import Foundation
import CoreData


extension ListData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListData> {
        return NSFetchRequest<ListData>(entityName: "ListData")
    }

    @NSManaged public var id: String
    @NSManaged public var listSections: NSSet
}

// MARK: Generated accessors for listSections
extension ListData {

    @objc(addListSectionsObject:)
    @NSManaged public func addToListSections(_ value: ListSection)

    @objc(removeListSectionsObject:)
    @NSManaged public func removeFromListSections(_ value: ListSection)

    @objc(addListSections:)
    @NSManaged public func addToListSections(_ values: NSSet)

    @objc(removeListSections:)
    @NSManaged public func removeFromListSections(_ values: NSSet)

}

extension ListData : Identifiable {

}
