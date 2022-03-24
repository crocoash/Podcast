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
