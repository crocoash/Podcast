//
//  Podcast+CoreDataClass.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 27.03.2022.
//
//

import Foundation
import CoreData

@objc(Podcast)
public class Podcast: NSManagedObject, Codable {

    private enum CodingKeys: String, CodingKey {
        case previewUrl
        case episodeFileExtension
        case artworkUrl160
        case episodeContentType
        case artworkUrl600
        case artworkUrl60
        case artistViewUrl
        case contentAdvisoryRating
        case trackViewUrl
        case trackTimeMillis
        case collectionViewUrl
        case episodeUrl
        case collectionId
        case collectionName
        case id = "trackId"
        case trackName
        case releaseDate
        case shortDescriptionMy = "shortDescription"
        case feedUrl
        case artistIds
        case closedCaptioning
        case country
        case descriptionMy = "description"
        case episodeGuid
        case kind
        case wrapperType
        case isDownLoad
        case progress
        case index
    }


    required convenience public init(from decoder: Decoder) throws {

        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            fatalError("mistake")
        }

        let entity = NSEntityDescription.entity(forEntityName: Podcast.description(), in: context)!
        self.init(entity: entity, insertInto: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        previewUrl = container.contains(.previewUrl) ? try container.decode(String?.self, forKey: .previewUrl) : nil
        episodeFileExtension = container.contains(.episodeFileExtension) ? try container.decode(String?.self, forKey: .episodeFileExtension) : nil
        artworkUrl160 = container.contains(.artworkUrl160) ? try container.decode(String?.self, forKey: .artworkUrl160) : nil
        episodeContentType = container.contains(.episodeContentType) ? try container.decode(String.self, forKey: .episodeContentType) : nil
        artworkUrl600 = container.contains(.artworkUrl600) ? try container.decode(String.self, forKey: .artworkUrl600) : nil
        artworkUrl60 = container.contains(.artworkUrl60) ? try container.decode(String.self, forKey: .artworkUrl60) : nil
        artistViewUrl = container.contains(.artistViewUrl) ? try container.decode(String.self, forKey: .artistViewUrl) : nil
        contentAdvisoryRating = container.contains(.contentAdvisoryRating) ? try container.decode(String?.self, forKey: .contentAdvisoryRating) : nil
        trackViewUrl = container.contains(.trackViewUrl) ? try container.decode(String.self, forKey: .trackViewUrl) : nil
        
        trackTimeMillis = container.contains(.trackTimeMillis) ? try container.decode(Int.self, forKey: .trackTimeMillis) as NSNumber : nil
        
        collectionViewUrl = container.contains(.collectionViewUrl) ? try container.decode(String.self, forKey: .collectionViewUrl) : nil
        episodeUrl = container.contains(.episodeUrl) ? try container.decode(String?.self, forKey: .episodeUrl) : nil
        collectionId = container.contains(.collectionId) ? try container.decode(Int.self, forKey: .collectionId) as NSNumber : nil
        collectionName = container.contains(.collectionName) ? try container.decode(String?.self, forKey: .collectionName) : nil
        id = container.contains(.id) ? try container.decode(Int.self, forKey: .id) as NSNumber : nil
        trackName = container.contains(.trackName) ? try container.decode(String.self, forKey: .trackName) : nil
        releaseDate = container.contains(.releaseDate) ? try container.decode(String?.self, forKey: .releaseDate) : nil
        shortDescriptionMy = container.contains(.shortDescriptionMy) ? try container.decode(String?.self, forKey: .shortDescriptionMy) : nil
        feedUrl = container.contains(.feedUrl) ? try container.decode(String?.self, forKey: .feedUrl) : nil
        artistIds = container.contains(.artistIds) ? try container.decode([Int]?.self, forKey: .artistIds) : nil
        closedCaptioning = container.contains(.closedCaptioning) ? try container.decode(String?.self, forKey: .closedCaptioning) : nil
        country = container.contains(.country) ? try container.decode(String?.self, forKey: .country) : nil
        descriptionMy = container.contains(.descriptionMy) ? try container.decode(String.self, forKey: .descriptionMy) : nil
        episodeGuid = container.contains(.episodeGuid) ? try container.decode(String?.self, forKey: .episodeGuid) : nil
        kind = container.contains(.kind) ? try container.decode(String?.self, forKey: .kind) : nil
        wrapperType = container.contains(.wrapperType) ? try container.decode(String?.self, forKey: .wrapperType) : nil
        isDownLoad = container.contains(.isDownLoad) ? try container.decode(Bool.self, forKey: .isDownLoad) : false
        progress = container.contains(.progress) ? try container.decode(Float.self, forKey: .progress) : 0
        index = container.contains(.index) ? try container.decode(Int.self, forKey: .index) as NSNumber : nil
    }
    
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        ///
        try container.encode(previewUrl, forKey: .previewUrl)
        try container.encode(episodeFileExtension, forKey: .episodeFileExtension )
        try container.encode(artworkUrl160, forKey: .artworkUrl160 )
        try container.encode(episodeContentType, forKey: .episodeContentType )
        try container.encode(artworkUrl600, forKey: .artworkUrl600 )
        try container.encode(artworkUrl60, forKey: .artworkUrl60 )
        try container.encode(artistViewUrl, forKey: .artistViewUrl )
        try container.encode(contentAdvisoryRating, forKey: .contentAdvisoryRating )
        try container.encode(trackViewUrl, forKey: .trackViewUrl )
        try container.encode(trackTimeMillis?.intValue, forKey: .trackTimeMillis )
        try container.encode(collectionViewUrl, forKey: .collectionViewUrl )
        try container.encode(episodeUrl, forKey: .episodeUrl )
        try container.encode(collectionId?.intValue, forKey: .collectionId )
        try container.encode(collectionName, forKey: .collectionName )
        try container.encode(id?.intValue, forKey: .id )
        try container.encode(trackName, forKey: .trackName )
        try container.encode(releaseDate, forKey: .releaseDate )
        try container.encode(shortDescriptionMy, forKey: .shortDescriptionMy )
        try container.encode(feedUrl, forKey: .feedUrl )
        try container.encode(artistIds, forKey: .artistIds )
        try container.encode(closedCaptioning, forKey: .closedCaptioning )
        try container.encode(country, forKey: .country )
        try container.encode(descriptionMy, forKey: .descriptionMy )
        try container.encode(episodeGuid, forKey: .episodeGuid )
        try container.encode(wrapperType, forKey: .wrapperType )
        try container.encode(isDownLoad, forKey: .isDownLoad )
        try container.encode(progress, forKey: .progress )
        try container.encode(index?.intValue, forKey: .index )
    }
}

extension Podcast: SearchProtocol {
    
    static var searchViewContext = DataStoreManager.shared.mainViewContext
    static var favoriteViewContext = DataStoreManager.shared.mainViewContext
    
    static var searchPodcastFetchResultController = DataStoreManager.shared.searchPodcastFetchResultController
    static var favoritePodcastFetchResultController = DataStoreManager.shared.favoritePodcastFetchResultController
    
    static var searchPodcasts: [Podcast] { (try? searchViewContext.fetch(Podcast.fetchRequest())) ?? [] }
    static var favoritePodcasts: [Podcast] { (try? favoriteViewContext.fetch(Podcast.fetchRequest())) ?? [] }
    
    
    static func removeAll(from viewContext: NSManagedObjectContext) {
        DataStoreManager.shared.removeAll(viewContext: viewContext, fetchRequest: Podcast.fetchRequest())
    }
    
    static func podcastIsInPlaylist(podcast: Podcast) -> Bool {
        return searchPodcasts.contains(podcast)
    }
    
    static func getSearchPodcast(for indexPath: IndexPath) -> Podcast {
        return searchPodcastFetchResultController.object(at: indexPath)
    }
    
    static func getfavoritePodcast(for indexPath: IndexPath) -> Podcast {
        return favoritePodcastFetchResultController.object(at: indexPath)
    }
    
    static func removeFromFavorites(podcast: Podcast) {
        searchViewContext.delete(podcast)
        searchViewContext.mySave()
    }
    
    static func addToFavorites(podcast: Podcast) {
        var newPodcast = Podcast(context: DataStoreManager.shared.mainViewContext)
        newPodcast.id = podcast.id
        newPodcast = podcast
        searchViewContext.mySave()
    }
    
    static func podcastIsDownload(podcast: Podcast) -> Bool {
        if let index = searchPodcasts.firstIndex(matching: podcast.id) {
            return searchPodcasts[index].isDownLoad == true
        }
        return false
    }
    
    static func downloadPodcast(podcast: Podcast) {
        /// TO DO:- Проверить кол-во и откуда
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: User.description())
        if let podcast = searchViewContext.object(with: podcast.objectID) as? Podcast {
            podcast.isDownLoad = true
            searchViewContext.mySave()
        }
    }
}
