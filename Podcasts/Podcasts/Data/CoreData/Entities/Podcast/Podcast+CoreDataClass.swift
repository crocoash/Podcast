//
//  Podcast+CoreDataClass.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 27.03.2022.
//
//

import Foundation
import CoreData
import UIKit

@objc(Podcast)
public class Podcast: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case previewUrl
        case episodeFileExtension
        case artworkUrl160
        case episodeContentType
        case artworkUrl600
        case artworkUrl60
        case contentAdvisoryRating
        case trackViewUrl
        case trackTimeMillis
        case collectionViewUrl
        case episodeUrl
        case collectionId
        case collectionName
        case identifier = "trackId"
        case trackName
        case releaseDate
        case shortDescriptionMy = "shortDescription"
        case feedUrl
        case genres
        case closedCaptioning
        case country
        case descriptionMy = "description"
        case episodeGuid
        case kind
        case wrapperType
        case artistName
        case trackCount
        case genreIds
        case favoritePodcast
        case likedMoment
        case listeningPodcast
    }
    
    //MARK: decoder
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.previewUrl =            try container.decodeIfPresent(String.self,forKey: .previewUrl)
        self.episodeFileExtension =  try container.decodeIfPresent(String.self,forKey: .episodeFileExtension)
        self.artworkUrl160 =         try container.decodeIfPresent(String.self,forKey: .artworkUrl160)
        self.episodeContentType =    try container.decodeIfPresent(String.self,forKey: .episodeContentType)
        self.artworkUrl600 =         try container.decodeIfPresent(String.self,forKey: .artworkUrl600)
        self.artworkUrl60 =          try container.decodeIfPresent(String.self,forKey: .artworkUrl60)
        self.contentAdvisoryRating = try container.decodeIfPresent(String.self,forKey: .contentAdvisoryRating)
        self.trackViewUrl =          try container.decodeIfPresent(String.self,forKey: .trackViewUrl)
        self.trackTimeMillis =       try container.decodeIfPresent(Int   .self,forKey: .trackTimeMillis) as? NSNumber
        self.collectionViewUrl =     try container.decodeIfPresent(String.self,forKey: .collectionViewUrl)
        self.episodeUrl =            try container.decodeIfPresent(String.self,forKey: .episodeUrl)
        self.collectionId =          try container.decodeIfPresent(Int   .self,forKey: .collectionId) as? NSNumber
        self.collectionName =        try container.decodeIfPresent(String.self,forKey: .collectionName)
        
        let intId = try container.decodeIfPresent(Int.self, forKey: .identifier)
        
        if let intId = intId {
            self.identifier = String(intId)
        } else {
            self.identifier = UUID().uuidString
        }
        self.trackName =             try container.decodeIfPresent(String.self,forKey: .trackName)
        self.releaseDate =           try container.decodeIfPresent(String.self,forKey: .releaseDate)
        self.shortDescriptionMy =    try container.decodeIfPresent(String.self,forKey: .shortDescriptionMy)
        self.feedUrl =               try container.decodeIfPresent(String.self,forKey: .feedUrl)
        self.trackCount =            try container.decodeIfPresent(Int   .self,forKey: .trackCount) as? NSNumber
        self.closedCaptioning =      try container.decodeIfPresent(String.self,forKey: .closedCaptioning)
        self.country =               try container.decodeIfPresent(String.self,forKey: .country)
        self.descriptionMy =         try container.decodeIfPresent(String.self,forKey: .descriptionMy)
        self.episodeGuid =           try container.decodeIfPresent(String.self,forKey: .episodeGuid)
        self.kind =                  try container.decodeIfPresent(String.self,forKey: .kind)
        self.artistName =            try container.decodeIfPresent(String.self,forKey: .artistName)
        self.wrapperType =           try container.decodeIfPresent(String.self,forKey: .wrapperType)
        
        
        if let genres = try? container.decode(Set<Genre>.self, forKey: .genres) as NSSet {
            self.genres = genres
        } else {
            var genres = [Genre]()
            if let ids = try? container.decode([String].self, forKey: .genreIds), let names = try? container.decode([String].self, forKey: .genres) {
                if ids.count == names.count {
                    for i in 0 ..< ids.count {

                        let genre = Genre(identifier: ids[i], name:  names[i], viewContext: nil)
                        genres.append(genre)
                    }
                }
            }
            self.genres = NSSet(array: genres)
        }
        
    }
    
    //MARK: encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(previewUrl,                forKey: .previewUrl)
        try container.encode(episodeFileExtension,      forKey: .episodeFileExtension)
        try container.encode(artworkUrl160,             forKey: .artworkUrl160)
        try container.encode(episodeContentType,        forKey: .episodeContentType)
        try container.encode(artworkUrl600,             forKey: .artworkUrl600)
        try container.encode(artworkUrl60,              forKey: .artworkUrl60)
        try container.encode(contentAdvisoryRating,     forKey: .contentAdvisoryRating)
        try container.encode(trackViewUrl,              forKey: .trackViewUrl)
        try container.encode(trackTimeMillis?.intValue, forKey: .trackTimeMillis)
        try container.encode(collectionViewUrl,         forKey: .collectionViewUrl)
        try container.encode(episodeUrl,                forKey: .episodeUrl)
        try container.encode(collectionId?.intValue,    forKey: .collectionId)
        try container.encode(collectionName,            forKey: .collectionName)
        try container.encode(Int(identifier),           forKey: .identifier)
        try container.encode(genres as? Set<Genre>,     forKey: .genres)
        try container.encode(trackName,                 forKey: .trackName)
        try container.encode(releaseDate,               forKey: .releaseDate)
        try container.encode(shortDescriptionMy,        forKey: .shortDescriptionMy)
        try container.encode(feedUrl,                   forKey: .feedUrl)
        try container.encode(closedCaptioning,          forKey: .closedCaptioning)
        try container.encode(country,                   forKey: .country)
        try container.encode(descriptionMy,             forKey: .descriptionMy)
        try container.encode(episodeGuid,               forKey: .episodeGuid)
        try container.encode(kind,                      forKey: .kind)
        try container.encode(wrapperType,               forKey: .wrapperType)
        try container.encode(artistName,                forKey: .artistName)
        try container.encode(trackCount?.intValue,      forKey: .trackCount)
    }
    
    //MARK: init
    @discardableResult
    required convenience init(_ entity: Podcast, viewContext: NSManagedObjectContext?, dataStoreManagerInput: DataStoreManagerInput?) {

        self.init(entity: Self.entity(), insertInto: viewContext)

        self.previewUrl =            entity.previewUrl
        self.episodeFileExtension =  entity.episodeFileExtension
        self.artworkUrl160 =         entity.artworkUrl160
        self.episodeContentType =    entity.episodeContentType
        self.artworkUrl600 =         entity.artworkUrl600
        self.artworkUrl60 =          entity.artworkUrl60
        self.contentAdvisoryRating = entity.contentAdvisoryRating
        self.trackViewUrl =          entity.trackViewUrl
        self.trackTimeMillis =       entity.trackTimeMillis
        self.collectionViewUrl =     entity.collectionViewUrl
        self.episodeUrl =            entity.episodeUrl
        self.collectionId =          entity.collectionId
        self.collectionName =        entity.collectionName
        self.identifier =            entity.identifier
        
        if let genres = entity.genres?.allObjects as? [Genre] {
            self.genres = NSSet(array: genres.compactMap { dataStoreManagerInput?.getFromCoreDataIfNoSavedNew(entity: $0) } ) as NSSet
        }
        
        self.trackName =          entity.trackName
        self.releaseDate =        entity.releaseDate
        self.shortDescriptionMy = entity.shortDescriptionMy
        self.feedUrl =            entity.feedUrl
        self.closedCaptioning =   entity.closedCaptioning
        self.country =            entity.country
        self.descriptionMy =      entity.descriptionMy
        self.episodeGuid =        entity.episodeGuid
        self.kind =               entity.kind
        self.wrapperType =        entity.wrapperType
        self.artistName =         entity.artistName
        self.trackCount =         entity.trackCount
    }
}

//MARK: - CoreDataProtocol
extension Podcast: CoreDataProtocol { }

//MARK: - InputPlayerProtocol
extension Podcast: InputTrackProtocol, TrackProtocol {
    
    var track: TrackProtocol {
        return self
    }
    
    var trackIdentifier: String {
        return identifier
    }
    
    var imageForBigPlayer: String? { image600 }
    var imageForSmallPlayer: String? { image60 }
    var imageForMpPlayer: String? { image160 }

    var genresString: String? { genres?.allObjects.reduce(into: "") { $0 += (($1 as? Genre)?.name ?? "") + ", " }  }
    var trackTimeMillisString: String? { trackTimeMillis?.minute }
  
    var currentTime: Float? {
        return listeningPodcast?.currentTime
    }
    
    var listeningProgress: Double? {
        return listeningPodcast?.progress
    }
    
    var duration: Double? {
        return 0
    }
    
    var url: URL? { episodeUrl.url }
    var image600: String? { artworkUrl600 }
    var image160: String? { artworkUrl160 ?? artworkUrl60 }
    var image60: String? { artworkUrl60 }
}

//MARK: - DownloadServiceProtocol
extension Podcast: DownloadProtocol, InputDownloadProtocol {
    
    var downloadEntity: DownloadProtocol {
        return self
    }
    
    var downloadEntityIdentifier: String {
        return identifier
    }
   
    var downloadUrl: String? {
        return episodeUrl
    }
}

//MARK: - Common
extension Podcast {
    
    var releaseDateInformation: Date {
        guard let releaseDate = releaseDate else { return Date() }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: releaseDate)
        return date ?? Date()
    }
    
    func formattedDate(dateFormat: String) -> String {
        releaseDateInformation.formattedDate(dateFormat: dateFormat)
    }
}

//MARK: - extension Collection
extension Collection where Element: Podcast {
    
    var sortPodcastsByGenre: [(key: String, podcasts: [Podcast])] {
        var array = [(key: String, podcasts: [Podcast])]()
        
        for podcast in self {
            if let genres = podcast.genres?.allObjects as? [Genre] {
            loop: for genre in genres {
                if let genreName = genre.name {
                    if array.isEmpty {
                        array.append((key: genreName, podcasts: [podcast]))
                        continue
                    }
                    for (index,value) in array.enumerated() {
                        if value.key == genreName {
                            array[index].podcasts.append(podcast)
                            continue loop
                        }
                    }
                    array.append((key: genreName, podcasts: [podcast]))
                }
            }
            }
        }
        let filteredArray = array.filter { !$0.podcasts.isEmpty }
        let sortedArray = filteredArray.map { (key: $0.key, podcasts: $0.podcasts.sorted { $0.releaseDateInformation < $1.releaseDateInformation })}
        return sortedArray
        
    }
    
    var sortPodcastsByNewest: [(key: String, podcasts: [Podcast])] {
        let array = self.sorted { $0.releaseDateInformation > $1.releaseDateInformation }
        return array.conform
    }
    
    var sortPodcastsByOldest: [(key: String, podcasts: [Podcast])] {
        let array = self.sorted { $0.releaseDateInformation < $1.releaseDateInformation }
        return array.conform
    }
    
    private var conform: [(key: String, podcasts: [Podcast])] {
        var array = [(key: String, podcasts: [Podcast])]()
        loop: for element in self {
            let date = element.formattedDate(dateFormat: "d MMM YYY")
            if array.isEmpty {
                array.append((key: date, podcasts: [element]))
                continue
            }
            for value in array.enumerated() where value.element.key == date  {
                array[value.offset].podcasts.append(element)
                continue loop
            }
            array.append((key: date, podcasts: [element]))
        }
        return array
    }
}

//MARK: - SearchCollectionViewCellType
extension Podcast: SearchCollectionViewCellType {
    
    var mainImageForSearchCollectionViewCell: String? {
        return image600
    }
}

//MARK: - FavoritePodcastTableViewCellType
extension Podcast: LikedPodcastTableViewCellType {
    
    var mainImageForFavoritePodcastTableViewCellType: String? {
        return artworkUrl600
    }
    
    var nameLabel: String? {
        return self.trackName
    }
}

//MARK: - PodcastCell
extension Podcast: PodcastCellProtocol, InputPodcastCell {
    
    var inputPodcastCell: PodcastCellProtocol {
        return self
    }
    
    var isFavorite: Bool {
        return favoritePodcast != nil
    }
    
    var trackDuration: String? { return trackTimeMillis?.minute }
    
    var dateDuration: String {
        return formattedDate(dateFormat: "d MMM YYY")
    }
    
    var imageForPodcastCell: String? { return image600 }
}

//MARK: - InputFavoriteType
extension Podcast: InputFavoriteType {
    
    var favoriteInputTypeIdentifier: String {
        return downloadEntityIdentifier
    }
}

extension Podcast: InputListeningManager {
    
    var podcast: Podcast {
        return self
    }
}
