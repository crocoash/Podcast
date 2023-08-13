//
//  Genre+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 11.06.2023.
//
//

import Foundation
import CoreData


extension Genre {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Genre> {
        return NSFetchRequest<Genre>(entityName: "Genre")
    }

    @NSManaged public var id: String
    @NSManaged public var name: String?
    @NSManaged public var podcasts: NSSet?

}

// MARK: Generated accessors for podcasts
extension Genre {

    @objc(addPodcastsObject:)
    @NSManaged public func addToPodcasts(_ value: Podcast)

    @objc(removePodcastsObject:)
    @NSManaged public func removeFromPodcasts(_ value: Podcast)

    @objc(addPodcasts:)
    @NSManaged public func addToPodcasts(_ values: NSSet)

    @objc(removePodcasts:)
    @NSManaged public func removeFromPodcasts(_ values: NSSet)

}

extension Genre : Identifiable {

}
