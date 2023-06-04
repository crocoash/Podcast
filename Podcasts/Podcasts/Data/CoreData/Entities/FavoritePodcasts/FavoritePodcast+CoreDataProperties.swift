//
//  FavoritePodcast+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 23.02.2023.
//
//

import Foundation
import CoreData


extension FavoritePodcast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritePodcast> {
        return NSFetchRequest<FavoritePodcast>(entityName: "FavoritePodcast")
    }

    @NSManaged public var date: Date?
    @NSManaged public var podcast: Podcast

}

extension FavoritePodcast : Identifiable {

}