//
//  FavouritePodcast+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 14.08.2023.
//
//

import Foundation
import CoreData


extension FavouritePodcast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavouritePodcast> {
        return NSFetchRequest<FavouritePodcast>(entityName: "FavouritePodcast")
    }

    @NSManaged public var dateAdd: Date
    @NSManaged public var id: String
    @NSManaged public var podcast: Podcast

}

extension FavouritePodcast : Identifiable {

}
