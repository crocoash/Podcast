//
//  ListData+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 14.08.2023.
//
//

import Foundation
import CoreData


extension ListData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListData> {
        return NSFetchRequest<ListData>(entityName: "ListData")
    }

    @NSManaged public var id: String?
    @NSManaged public var listSection: NSSet?

}

// MARK: Generated accessors for listSection
extension ListData {

    @objc(addListSectionObject:)
    @NSManaged public func addToListSection(_ value: ListSection)

    @objc(removeListSectionObject:)
    @NSManaged public func removeFromListSection(_ value: ListSection)

    @objc(addListSection:)
    @NSManaged public func addToListSection(_ values: NSSet)

    @objc(removeListSection:)
    @NSManaged public func removeFromListSection(_ values: NSSet)

}

extension ListData : Identifiable {

}
