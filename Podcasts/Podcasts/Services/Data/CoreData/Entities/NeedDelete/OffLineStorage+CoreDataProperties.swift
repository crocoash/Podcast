//
//  OffLineStorage+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 21.01.2023.
//
//

import Foundation
import CoreData


extension OffLineStorage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OffLineStorage> {
        return NSFetchRequest<OffLineStorage>(entityName: "OffLineStorage")
    }

    @NSManaged public var removeLikedMoment: [String]?
    @NSManaged public var removeFavoritePodcast: [String]?
    @NSManaged public var addFavoritePodcast: [FavoritePodcast]?
    @NSManaged public var addLikedMoment: [LikedMoment]?

}

// MARK: Generated accessors for addFavoritePodcast
extension OffLineStorage {

    @objc(addAddFavoritePodcastObject:)
    @NSManaged public func addToAddFavoritePodcast(_ value: FavoritePodcast)

    @objc(removeAddFavoritePodcastObject:)
    @NSManaged public func removeFromAddFavoritePodcast(_ value: FavoritePodcast)

    @objc(addAddFavoritePodcast:)
    @NSManaged public func addToAddFavoritePodcast(_ values: [FavoritePodcast])

    @objc(removeAddFavoritePodcast:)
    @NSManaged public func removeFromAddFavoritePodcast(_ values: [FavoritePodcast])

}

// MARK: Generated accessors for addLikedMoment
extension OffLineStorage {

    @objc(addAddLikedMomentObject:)
    @NSManaged public func addToAddLikedMoment(_ value: LikedMoment)

    @objc(removeAddLikedMomentObject:)
    @NSManaged public func removeFromAddLikedMoment(_ value: LikedMoment)

    @objc(addAddLikedMoment:)
    @NSManaged public func addToAddLikedMoment(_ values: [LikedMoment])

    @objc(removeAddLikedMoment:)
    @NSManaged public func removeFromAddLikedMoment(_ values: [LikedMoment])

}

extension OffLineStorage : Identifiable {

}
