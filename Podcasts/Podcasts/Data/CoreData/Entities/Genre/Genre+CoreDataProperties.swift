//
//  Genre+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 23.02.2023.
//
//

import Foundation
import CoreData


extension Genre {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Genre> {
        return NSFetchRequest<Genre>(entityName: "Genre")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var podcast: NSSet?

}

// MARK: Generated accessors for podcast
extension Genre {

    @objc(addPodcastObject:)
    @NSManaged public func addToPodcast(_ value: Podcast)

    @objc(removePodcastObject:)
    @NSManaged public func removeFromPodcast(_ value: Podcast)

    @objc(addPodcast:)
    @NSManaged public func addToPodcast(_ values: NSSet)

    @objc(removePodcast:)
    @NSManaged public func removeFromPodcast(_ values: NSSet)

}

extension Genre : Identifiable {

}
