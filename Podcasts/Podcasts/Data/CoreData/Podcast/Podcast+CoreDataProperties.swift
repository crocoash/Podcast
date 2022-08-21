//
//  Podcast+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 25.04.2022.
//
//

import Foundation
import CoreData


extension Podcast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Podcast> {
        return NSFetchRequest<Podcast>(entityName: Self.entityName)
    }

    @NSManaged public var artistIds: [Int]?
    @NSManaged public var artistViewUrl: String?
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
    @NSManaged public var id: NSNumber?
    @NSManaged public var index: NSNumber?
    @NSManaged public var kind: String?
    @NSManaged public var previewUrl: String?
    @NSManaged public var progress: Float
    @NSManaged public var releaseDate: String?
    @NSManaged public var shortDescriptionMy: String?
    @NSManaged public var trackName: String?
    @NSManaged public var trackTimeMillis: NSNumber?
    @NSManaged public var trackViewUrl: String?
    @NSManaged public var wrapperType: String?

}

extension Podcast : Identifiable {

}
