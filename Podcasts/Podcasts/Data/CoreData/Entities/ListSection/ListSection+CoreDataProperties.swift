//
//  ListSection+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 08.08.2023.
//
//

import Foundation
import CoreData


extension ListSection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListSection> {
        return NSFetchRequest<ListSection>(entityName: "ListSection")
    }

    @NSManaged public var isActive: Bool
    @NSManaged public var nameOfEntity: String
    @NSManaged public var nameOfSection: String
    @NSManaged public var id: String
    @NSManaged public var sequenceNumber: NSNumber
    @NSManaged public var listData: ListData

}

extension ListSection : Identifiable {

}
