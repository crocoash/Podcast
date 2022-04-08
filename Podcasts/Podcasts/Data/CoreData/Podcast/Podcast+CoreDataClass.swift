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
public class Podcast: NSManagedObject, Decodable {

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
        case isFavorite
        case isSearched
    }


    required convenience public init(from decoder: Decoder) throws {

        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            fatalError("mistake")
        }

        let entity = NSEntityDescription.entity(forEntityName: Podcast.description(), in: context)!
        self.init(entity: entity, insertInto: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        previewUrl = try container.decodeIfPresent(String.self, forKey: .previewUrl)
        episodeFileExtension = try container.decodeIfPresent(String.self, forKey: .episodeFileExtension)
        artworkUrl160 = try container.decodeIfPresent(String.self, forKey: .artworkUrl160)
        episodeContentType = try container.decodeIfPresent(String.self, forKey: .episodeContentType)
        artworkUrl600 = try container.decodeIfPresent(String.self, forKey: .artworkUrl600)
        artworkUrl60 = try container.decodeIfPresent(String.self, forKey: .artworkUrl60)
        artistViewUrl = try container.decodeIfPresent(String.self, forKey: .artistViewUrl)
        contentAdvisoryRating = try container.decodeIfPresent(String.self, forKey: .contentAdvisoryRating)
        trackViewUrl = try container.decodeIfPresent(String.self, forKey: .trackViewUrl)
        
        trackTimeMillis = try container.decodeIfPresent(Int.self, forKey: .trackTimeMillis) as? NSNumber
        
        collectionViewUrl = try container.decodeIfPresent(String.self, forKey: .collectionViewUrl)
        episodeUrl = try container.decodeIfPresent(String.self, forKey: .episodeUrl)
        collectionId = try container.decodeIfPresent(Int.self, forKey: .collectionId) as? NSNumber
        collectionName = try container.decodeIfPresent(String.self, forKey: .collectionName)
        id = try container.decodeIfPresent(Int.self, forKey: .id) as? NSNumber
        trackName = try container.decodeIfPresent(String.self, forKey: .trackName)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        shortDescriptionMy = try container.decodeIfPresent(String.self, forKey: .shortDescriptionMy)
        feedUrl = try container.decodeIfPresent(String.self, forKey: .feedUrl)
        artistIds = try container.decodeIfPresent([Int].self, forKey: .artistIds)
        closedCaptioning = try container.decodeIfPresent(String.self, forKey: .closedCaptioning)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        descriptionMy = try container.decodeIfPresent(String.self, forKey: .descriptionMy)
        episodeGuid = try container.decodeIfPresent(String.self, forKey: .episodeGuid)
        kind = try container.decodeIfPresent(String.self, forKey: .kind)
        wrapperType = try container.decodeIfPresent(String.self, forKey: .wrapperType)
        isDownLoad = try container.decodeIfPresent(Bool.self, forKey: .isDownLoad) ?? false
        progress = try container.decodeIfPresent(Float.self, forKey: .progress) ?? 0
        index = try container.decodeIfPresent(Int.self, forKey: .index) as? NSNumber
        
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        isSearched = try container.decodeIfPresent(Bool.self, forKey: .isSearched) ?? true
    }
    
    
//    public func encode(to encoder: Encoder) throws {
//
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        ///
//        try container.encode(previewUrl, forKey: .previewUrl)
//        try container.encode(episodeFileExtension, forKey: .episodeFileExtension )
//        try container.encode(artworkUrl160, forKey: .artworkUrl160 )
//        try container.encode(episodeContentType, forKey: .episodeContentType )
//        try container.encode(artworkUrl600, forKey: .artworkUrl600 )
//        try container.encode(artworkUrl60, forKey: .artworkUrl60 )
//        try container.encode(artistViewUrl, forKey: .artistViewUrl )
//        try container.encode(contentAdvisoryRating, forKey: .contentAdvisoryRating )
//        try container.encode(trackViewUrl, forKey: .trackViewUrl )
//        try container.encode(trackTimeMillis?.intValue, forKey: .trackTimeMillis )
//        try container.encode(collectionViewUrl, forKey: .collectionViewUrl )
//        try container.encode(episodeUrl, forKey: .episodeUrl )
//        try container.encode(collectionId?.intValue, forKey: .collectionId )
//        try container.encode(collectionName, forKey: .collectionName )
//        try container.encode(id?.intValue, forKey: .id )
//        try container.encode(trackName, forKey: .trackName )
//        try container.encode(releaseDate, forKey: .releaseDate )
//        try container.encode(shortDescriptionMy, forKey: .shortDescriptionMy )
//        try container.encode(feedUrl, forKey: .feedUrl )
//        try container.encode(artistIds, forKey: .artistIds )
//        try container.encode(closedCaptioning, forKey: .closedCaptioning )
//        try container.encode(country, forKey: .country )
//        try container.encode(descriptionMy, forKey: .descriptionMy )
//        try container.encode(episodeGuid, forKey: .episodeGuid )
//        try container.encode(wrapperType, forKey: .wrapperType )
//        try container.encode(isDownLoad, forKey: .isDownLoad )
//        try container.encode(progress, forKey: .progress )
//        try container.encode(index?.intValue, forKey: .index )
//    }
}

extension Podcast {
    
    static var viewContext = DataStoreManager.shared.viewContext
    
    static var searchPodcastFetchResultController = DataStoreManager.shared.searchPodcastFetchResultController
    static var favoritePodcastFetchResultController = DataStoreManager.shared.favoritePodcastFetchResultController
    
    static var searchPodcasts: [Podcast] { searchPodcastFetchResultController.fetchedObjects ?? [] }
    static var favoritePodcasts: [Podcast] { (try? viewContext.fetch(Podcast.fetchRequest())) ?? [] }
    
    
    static func removeAll() {
        DataStoreManager.shared.removeAll(fetchRequest: Podcast.fetchRequest())
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
    
    static func newSearch() {
        searchPodcastFetchResultController.fetchedObjects?.forEach {
            $0.isSearched = false
        }
        viewContext.mySave()
    }
    
    static func removeFromFavorites(podcast: Podcast) {
        viewContext.delete(podcast)
        viewContext.mySave()
    }
    
    static func addToFavorites(podcast: Podcast) {
        var newPodcast = Podcast(context: DataStoreManager.shared.viewContext)
        newPodcast.id = podcast.id
        newPodcast = podcast
        viewContext.mySave()
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
        if let podcast = viewContext.object(with: podcast.objectID) as? Podcast {
            podcast.isDownLoad = true
            viewContext.mySave()
        }
    }
}
