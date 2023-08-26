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
        case artistId
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
        case id = "trackId"
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
        case favouritePodcast
        case likedMoment
        case listeningPodcast
    }
    
    //MARK: decoder
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.previewUrl =            try container.decodeIfPresent(String.self, forKey: .previewUrl)
        self.episodeFileExtension =  try container.decodeIfPresent(String.self, forKey: .episodeFileExtension)
        self.artworkUrl160 =         try container.decodeIfPresent(String.self, forKey: .artworkUrl160)
        self.episodeContentType =    try container.decodeIfPresent(String.self, forKey: .episodeContentType)
        self.artworkUrl600 =         try container.decodeIfPresent(String.self, forKey: .artworkUrl600)
        self.artworkUrl60 =          try container.decodeIfPresent(String.self, forKey: .artworkUrl60)
        self.contentAdvisoryRating = try container.decodeIfPresent(String.self, forKey: .contentAdvisoryRating)
        self.trackViewUrl =          try container.decodeIfPresent(String.self, forKey: .trackViewUrl)
        self.trackTimeMillis =       try container.decodeIfPresent(Int   .self, forKey: .trackTimeMillis) as? NSNumber
        self.collectionViewUrl =     try container.decodeIfPresent(String.self, forKey: .collectionViewUrl)
        self.episodeUrl =            try container.decodeIfPresent(String.self, forKey: .episodeUrl)
        self.collectionId =          try container.decodeIfPresent(Int   .self, forKey: .collectionId) as? NSNumber
        self.collectionName =        try container.decodeIfPresent(String.self, forKey: .collectionName)
        
        let intId = try container.decodeIfPresent(Int.self, forKey: .id)
        
        if let intId = intId {
            self.id = String(intId)
        } else {
            self.id = UUID().uuidString
        }
        self.trackName =             try container.decodeIfPresent(String.self, forKey: .trackName)
        self.releaseDate =           try container.decodeIfPresent(String.self, forKey: .releaseDate)
        self.shortDescriptionMy =    try container.decodeIfPresent(String.self, forKey: .shortDescriptionMy)
        self.feedUrl =               try container.decodeIfPresent(String.self, forKey: .feedUrl)
        self.trackCount =            try container.decodeIfPresent(Int   .self, forKey: .trackCount) as? NSNumber
        self.closedCaptioning =      try container.decodeIfPresent(String.self, forKey: .closedCaptioning)
        self.country =               try container.decodeIfPresent(String.self, forKey: .country)
        self.descriptionMy =         try container.decodeIfPresent(String.self, forKey: .descriptionMy)
        self.episodeGuid =           try container.decodeIfPresent(String.self, forKey: .episodeGuid)
        self.kind =                  try container.decodeIfPresent(String.self, forKey: .kind)
        self.artistName =            try container.decodeIfPresent(String.self, forKey: .artistName)
        self.artistId =              try container.decodeIfPresent(Int   .self, forKey: .artistId) as? NSNumber
        self.wrapperType =           try container.decodeIfPresent(String.self, forKey: .wrapperType)
        
        
        if let genres = try? container.decode(Set<Genre>.self, forKey: .genres) as NSSet {
            self.genres = genres
        } else {
            var genres = [Genre]()
            if let ids = try? container.decode([String].self, forKey: .genreIds), let names = try? container.decode([String].self, forKey: .genres) {
                if ids.count == names.count {
                    for i in 0 ..< ids.count {

                        let genre = Genre(id: ids[i], name:  names[i])
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
        
        try container.encodeIfPresent(previewUrl,                forKey: .previewUrl)
        try container.encodeIfPresent(episodeFileExtension,      forKey: .episodeFileExtension)
        try container.encodeIfPresent(artworkUrl160,             forKey: .artworkUrl160)
        try container.encodeIfPresent(episodeContentType,        forKey: .episodeContentType)
        try container.encodeIfPresent(artworkUrl600,             forKey: .artworkUrl600)
        try container.encodeIfPresent(artworkUrl60,              forKey: .artworkUrl60)
        try container.encodeIfPresent(contentAdvisoryRating,     forKey: .contentAdvisoryRating)
        try container.encodeIfPresent(trackViewUrl,              forKey: .trackViewUrl)
        try container.encodeIfPresent(trackTimeMillis?.intValue, forKey: .trackTimeMillis)
        try container.encodeIfPresent(collectionViewUrl,         forKey: .collectionViewUrl)
        try container.encodeIfPresent(episodeUrl,                forKey: .episodeUrl)
        try container.encodeIfPresent(collectionId?.intValue,    forKey: .collectionId)
        try container.encodeIfPresent(collectionName,            forKey: .collectionName)
        try container.encodeIfPresent(Int(id),           forKey: .id)
        try container.encodeIfPresent(genres as? Set<Genre>,     forKey: .genres)
        try container.encodeIfPresent(trackName,                 forKey: .trackName)
        try container.encodeIfPresent(releaseDate,               forKey: .releaseDate)
        try container.encodeIfPresent(shortDescriptionMy,        forKey: .shortDescriptionMy)
        try container.encodeIfPresent(feedUrl,                   forKey: .feedUrl)
        try container.encodeIfPresent(closedCaptioning,          forKey: .closedCaptioning)
        try container.encodeIfPresent(country,                   forKey: .country)
        try container.encodeIfPresent(descriptionMy,             forKey: .descriptionMy)
        try container.encodeIfPresent(episodeGuid,               forKey: .episodeGuid)
        try container.encodeIfPresent(kind,                      forKey: .kind)
        try container.encodeIfPresent(wrapperType,               forKey: .wrapperType)
        try container.encodeIfPresent(artistName,                forKey: .artistName)
        try container.encodeIfPresent(artistId?.intValue,        forKey: .artistId)
        try container.encodeIfPresent(trackCount?.intValue,      forKey: .trackCount)
    }
    
    //MARK: init
    @discardableResult
    required convenience init(_ entity: Podcast, viewContext: NSManagedObjectContext, dataStoreManagerInput: DataStoreManagerInput) {

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
        self.id =            entity.id

        if let genres = entity.genres as? Set<Genre> {
            let genres = genres.compactMap { dataStoreManagerInput.getFromCoreDataIfNoSavedNew(entity: $0) }
            self.genres = NSSet(array: genres)
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
        self.artistId =           entity.artistId
        self.trackCount =         entity.trackCount

    }
}

//MARK: - CoreDataProtocol
extension Podcast: CoreDataProtocol {
    
    static var defaultSortDescription: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(Podcast.trackName), ascending: true)]
    }
}

//MARK: - PlayerInputProtocol
extension Podcast: TrackProtocol {
    
    var duration: Double? {
        return listeningPodcast?.duration
    }

    var track: TrackProtocol {
        return self
    }
    
    var trackId: String {
        return id
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
    
    var url: URL? {
//        if episodeFileExtension == "mp3" {
            return episodeUrl.url
//        }
//        return nil
    }
    var image600: String? { artworkUrl600 }
    var image160: String? { artworkUrl160 ?? artworkUrl60 }
    var image60: String? { artworkUrl60 }
}

//MARK: - DownloadServiceProtocol
extension Podcast: DownloadProtocol, InputDownloadProtocol {
  
    var downloadEntity: DownloadProtocol {
        return self
    }
    
    var downloadId: String {
        return id
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

//MARK: - FavouritePodcastTableViewCellType
extension Podcast: LikedPodcastTableViewCellType {
    
    var mainImageForFavouritePodcastTableViewCellType: String? {
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
    
    var isFavourite: Bool {
        return favouritePodcast != nil
    }
    
    var trackDuration: String? { return trackTimeMillis?.minute }
    
    var dateDuration: String {
        return formattedDate(dateFormat: "d MMM YYY")
    }
    
    var imageForPodcastCell: String? { return image600 }
}

//MARK: - InputFavouriteType
extension Podcast: InputFavouriteType {
    
    var favouriteInputTypeid: String {
        return id
    }
}
