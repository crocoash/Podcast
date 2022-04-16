//
//  LikedMoment+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 15.04.2022.
//
//

import Foundation
import CoreData


extension LikedMoment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LikedMoment> {
        return NSFetchRequest<LikedMoment>(entityName: "LikedMoment")
    }

    @NSManaged public var moment: Double
    @NSManaged public var podcast: Podcast

}

extension LikedMoment : Identifiable {

}
