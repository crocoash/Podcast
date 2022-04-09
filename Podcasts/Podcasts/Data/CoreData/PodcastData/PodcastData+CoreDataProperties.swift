//
//  PodcastData+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 09.04.2022.
//
//

import Foundation
import CoreData


extension PodcastData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PodcastData> {
        return NSFetchRequest<PodcastData>(entityName: "PodcastData")
    }

    @NSManaged public var resultCount: Int32
    @NSManaged public var results: NSSet

}

// MARK: Generated accessors for results
extension PodcastData {

    @objc(addResultsObject:)
    @NSManaged public func addToResults(_ value: Podcast)

    @objc(removeResultsObject:)
    @NSManaged public func removeFromResults(_ value: Podcast)

    @objc(addResults:)
    @NSManaged public func addToResults(_ values: NSSet)

    @objc(removeResults:)
    @NSManaged public func removeFromResults(_ values: NSSet)

}

extension PodcastData : Identifiable {

}
