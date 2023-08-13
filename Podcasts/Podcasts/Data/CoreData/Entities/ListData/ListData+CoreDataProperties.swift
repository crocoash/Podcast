//
//  ListData+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 08.08.2023.
//
//

import Foundation
import CoreData


extension ListData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListData> {
        return NSFetchRequest<ListData>(entityName: "ListData")
    }

    @NSManaged public var id: String
    @NSManaged public var listSection: ListSection

}

extension ListData : Identifiable {

}
