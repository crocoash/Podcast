//
//  FavoritePodcast+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 04.05.2022.
//
//

import Foundation
import CoreData


extension FavoritePodcast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritePodcast> {
        return NSFetchRequest<FavoritePodcast>(entityName: "FavoritePodcast")
    }

    @NSManaged public var idd: String
    @NSManaged public var podcast: Podcast

}

extension FavoritePodcast : Identifiable {

}
