//
//  Podcast+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 17.06.2023.
//
//

import Foundation
import CoreData


extension Podcast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Podcast> {
        return NSFetchRequest<Podcast>(entityName: "Podcast")
    }

    @NSManaged public var artistName: String?
    @NSManaged public var artworkUrl60: String?
    @NSManaged public var artworkUrl160: String?
    @NSManaged public var artworkUrl600: String?
    @NSManaged public var closedCaptioning: String?
    @NSManaged public var collectionId: NSNumber?
    @NSManaged public var collectionName: String?
    @NSManaged public var collectionViewUrl: String?
    @NSManaged public var contentAdvisoryRating: String?
    @NSManaged public var country: String?
    @NSManaged public var descriptionMy: String?
    @NSManaged public var episodeContentType: String?
    @NSManaged public var episodeFileExtension: String?
    @NSManaged public var episodeGuid: String?
    @NSManaged public var episodeUrl: String?
    @NSManaged public var feedUrl: String?
    @NSManaged public var identifier: String
    @NSManaged public var kind: String?
    @NSManaged public var previewUrl: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var shortDescriptionMy: String?
    @NSManaged public var trackCount: NSNumber?
    @NSManaged public var trackName: String?
    @NSManaged public var trackTimeMillis: NSNumber?
    @NSManaged public var trackViewUrl: String?
    @NSManaged public var wrapperType: String?
    @NSManaged public var favoritePodcast: FavoritePodcast?
    @NSManaged public var genres: NSSet?
    @NSManaged public var likedMoment: NSSet?
    @NSManaged public var listeningPodcast: ListeningPodcast?

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


//protocol Identifiable {
//    var id: String { get }
//}
