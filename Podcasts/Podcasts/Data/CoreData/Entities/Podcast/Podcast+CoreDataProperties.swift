//
//  Podcast+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 05.08.2023.
//
//

import Foundation
import CoreData


extension Podcast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Podcast> {
        return NSFetchRequest<Podcast>(entityName: "Podcast")
    }
}

// MARK: Generated accessors for genres
extension Podcast {

    @objc(addGenresObject:)
    @NSManaged public func addToGenres(_ value: Genre)

    @objc(removeGenresObject:)
    @NSManaged public func removeFromGenres(_ value: Genre)

    @objc(addGenres:)
    @NSManaged public func addToGenres(_ values: NSSet)

    @objc(removeGenres:)
    @NSManaged public func removeFromGenres(_ values: NSSet)

}

// MARK: Generated accessors for likedMoment
extension Podcast {

    @objc(addLikedMomentObject:)
    @NSManaged public func addToLikedMoment(_ value: LikedMoment)

    @objc(removeLikedMomentObject:)
    @NSManaged public func removeFromLikedMoment(_ value: LikedMoment)

    @objc(addLikedMoment:)
    @NSManaged public func addToLikedMoment(_ values: NSSet)

    @objc(removeLikedMoment:)
    @NSManaged public func removeFromLikedMoment(_ values: NSSet)

}

extension Podcast : Identifiable {

}
