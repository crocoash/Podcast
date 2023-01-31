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
        return NSFetchRequest<FavoritePodcast>(entityName: Self.entityName)
    }

    @NSManaged public var idd: String
    @NSManaged public var podcast: Podcast
    
    var key: String { podcast.id?.stringValue ?? "" }
    var viewContext: NSManagedObjectContext { DataStoreManager.shared.viewContext }
}

extension FavoritePodcast : Identifiable {

}
