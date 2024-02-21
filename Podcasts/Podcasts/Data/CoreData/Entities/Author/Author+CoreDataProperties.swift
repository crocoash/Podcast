//
//  Author+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 08.08.2023.
//
//

import Foundation
import CoreData


extension Author {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Author> {
        return NSFetchRequest<Author>(entityName: "Author")
    }

    @NSManaged public var artistID: Int32
    @NSManaged public var artistLinkURL: String?
    @NSManaged public var artistName: String?
    @NSManaged public var artistType: String?
    @NSManaged public var authorData: AuthorData?

}
