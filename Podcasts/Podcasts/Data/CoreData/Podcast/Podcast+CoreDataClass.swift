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
}

extension Podcast {
    
    static var viewContext = DataStoreManager.shared.viewContext
    
    //MARK: - Search

    
    //MARK: - Favorite
    static var favoritePodcastFetchResultController = DataStoreManager.shared.favoritePodcastFetchResultController
    static var favoritePodcasts: [Podcast] { (try? viewContext.fetch(Podcast.fetchRequest())) ?? [] }
    
    static func getfavoritePodcast(for indexPath: IndexPath) -> Podcast {
        return favoritePodcastFetchResultController.object(at: indexPath)
    }
    
    static func removaAllFavorites() {
        favoritePodcastFetchResultController.fetchedObjects?.forEach {
            viewContext.delete($0)
        }
        viewContext.mySave()
    }
    
    static func removeFromFavorites(indexPath: IndexPath) {
        let podcast = Podcast.getfavoritePodcast(for: indexPath)
        podcast.isFavorite = false
        viewContext.mySave()
    }
    
    static func addToFavorites(podcast: Podcast) {
        var newPodcast = Podcast(context: DataStoreManager.shared.viewContext)
        newPodcast.id = podcast.id
        newPodcast.isSearched = false
        newPodcast.isFavorite = true
        newPodcast = podcast
        viewContext.mySave()
    }
    
    //MARK: - Common
    static func removeAll() {
        DataStoreManager.shared.removeAll(fetchRequest: Podcast.fetchRequest())
    }

    static func downloadPodcast(podcast: Podcast) {
        if let podcast = viewContext.object(with: podcast.objectID) as? Podcast {
            podcast.isDownLoad = true
            viewContext.mySave()
        }
    }
}
