//
//  LikedMoment+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 11.06.2023.
//
//

import Foundation
import CoreData


extension LikedMoment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LikedMoment> {
        return NSFetchRequest<LikedMoment>(entityName: "LikedMoment")
    }

    @NSManaged public var moment: Double
    @NSManaged public var id: String?
    @NSManaged public var podcast: Podcast?

}

extension LikedMoment : Identifiable {

}
