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
        case favoritePodcast
        case likedMoment
        case listeningPodcast
    }
    
    //MARK: decoder
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        previewUrl =            try container.decodeIfPresent(String.self,           forKey: .previewUrl)
        episodeFileExtension =  try container.decodeIfPresent(String.self,           forKey: .episodeFileExtension)
        artworkUrl160 =         try container.decodeIfPresent(String.self,           forKey: .artworkUrl160)
        episodeContentType =    try container.decodeIfPresent(String.self,           forKey: .episodeContentType)
        artworkUrl600 =         try container.decodeIfPresent(String.self,           forKey: .artworkUrl600)
        artworkUrl60 =          try container.decodeIfPresent(String.self,           forKey: .artworkUrl60)
        contentAdvisoryRating = try container.decodeIfPresent(String.self,           forKey: .contentAdvisoryRating)
        trackViewUrl =          try container.decodeIfPresent(String.self,           forKey: .trackViewUrl)
        trackTimeMillis =       try container.decodeIfPresent(Int   .self,           forKey: .trackTimeMillis) as? NSNumber
        collectionViewUrl =     try container.decodeIfPresent(String.self,           forKey: .collectionViewUrl)
        episodeUrl =            try container.decodeIfPresent(String.self,           forKey: .episodeUrl)
        collectionId =          try container.decodeIfPresent(Int   .self,           forKey: .collectionId) as? NSNumber
        collectionName =        try container.decodeIfPresent(String.self,           forKey: .collectionName)
        id =                    try container.decodeIfPresent(Int   .self,           forKey: .id) as? NSNumber
        trackName =             try container.decodeIfPresent(String.self,           forKey: .trackName)
        releaseDate =           try container.decodeIfPresent(String.self,           forKey: .releaseDate)
        shortDescriptionMy =    try container.decodeIfPresent(String.self,           forKey: .shortDescriptionMy)
        feedUrl =               try container.decodeIfPresent(String.self,           forKey: .feedUrl)
        trackCount =            try container.decodeIfPresent(Int   .self,           forKey: .trackCount) as? NSNumber
        closedCaptioning =      try container.decodeIfPresent(String.self,           forKey: .closedCaptioning)
        country =               try container.decodeIfPresent(String.self,           forKey: .country)
        descriptionMy =         try container.decodeIfPresent(String.self,           forKey: .descriptionMy)
        episodeGuid =           try container.decodeIfPresent(String.self,           forKey: .episodeGuid)
        kind =                  try container.decodeIfPresent(String.self,           forKey: .kind)
        artistName =            try container.decodeIfPresent(String.self,           forKey: .artistName)
        wrapperType =           try container.decodeIfPresent(String.self,           forKey: .wrapperType)
        
        
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
        
        try container.encode(previewUrl,                      forKey: .previewUrl)
        try container.encode(episodeFileExtension,            forKey: .episodeFileExtension)
        try container.encode(artworkUrl160,                   forKey: .artworkUrl160)
        try container.encode(episodeContentType,              forKey: .episodeContentType)
        try container.encode(artworkUrl600,                   forKey: .artworkUrl600)
        try container.encode(artworkUrl60,                    forKey: .artworkUrl60)
        try container.encode(contentAdvisoryRating,           forKey: .contentAdvisoryRating)
        try container.encode(trackViewUrl,                    forKey: .trackViewUrl)
        try container.encode(trackTimeMillis?.intValue,       forKey: .trackTimeMillis)
        try container.encode(collectionViewUrl,               forKey: .collectionViewUrl)
        try container.encode(episodeUrl,                      forKey: .episodeUrl)
        try container.encode(collectionId?.intValue,          forKey: .collectionId)
        try container.encode(collectionName,                  forKey: .collectionName)
        try container.encode(id?.intValue,                     forKey: .id)
        try container.encode(genres as? Set<Genre>,           forKey: .genres)
        try container.encode(trackName,                       forKey: .trackName)
        try container.encode(releaseDate,                     forKey: .releaseDate)
        try container.encode(shortDescriptionMy,              forKey: .shortDescriptionMy)
        try container.encode(feedUrl,                         forKey: .feedUrl)
        try container.encode(closedCaptioning,                forKey: .closedCaptioning)
        try container.encode(country,                         forKey: .country)
        try container.encode(descriptionMy,                   forKey: .descriptionMy)
        try container.encode(episodeGuid,                     forKey: .episodeGuid)
        try container.encode(kind,                            forKey: .kind)
        try container.encode(wrapperType,                     forKey: .wrapperType)
        try container.encode(artistName,                      forKey: .artistName)
        try container.encode(trackCount?.intValue,            forKey: .trackCount) 
    }
    
    //MARK: init
    convenience init(podcast: Podcast) {
     
        self.init(entity: Self.entity(), insertInto: Self.viewContext)
        
        self.previewUrl =             podcast.previewUrl
        self.episodeFileExtension =   podcast.episodeFileExtension
        self.artworkUrl160 =          podcast.artworkUrl160
        self.episodeContentType =     podcast.episodeContentType
        self.artworkUrl600 =          podcast.artworkUrl600
        self.artworkUrl60 =           podcast.artworkUrl60
        self.contentAdvisoryRating =  podcast.contentAdvisoryRating
        self.trackViewUrl =           podcast.trackViewUrl
        self.trackTimeMillis =        podcast.trackTimeMillis
        self.collectionViewUrl =      podcast.collectionViewUrl
        self.episodeUrl =             podcast.episodeUrl
        self.collectionId =           podcast.collectionId
        self.collectionName =         podcast.collectionName
        self.id =                     podcast.id
        self.genres =                 NSSet(array: podcast.genres!.allObjects.compactMap { ($0 as! Genre).getFromCoreDataIfNoSavedNew() } ) as NSSet
        self.trackName =              podcast.trackName
        self.releaseDate =            podcast.releaseDate
        self.shortDescriptionMy =     podcast.shortDescriptionMy
        self.feedUrl =                podcast.feedUrl
        self.closedCaptioning =       podcast.closedCaptioning
        self.country =                podcast.country
        self.descriptionMy =          podcast.descriptionMy
        self.episodeGuid =            podcast.episodeGuid
        self.kind =                   podcast.kind
        self.wrapperType =            podcast.wrapperType
        self.artistName =             podcast.artistName
        self.trackCount =             podcast.trackCount
        
        saveInit()
    }
}

//MARK: - CoreDataProtocol
extension Podcast: CoreDataProtocol {
    typealias T = Podcast

    static var allObjectsFromCoreData: [Podcast] { Self.viewContext.fetchObjects(Self.self) }

    func getFromCoreDataIfNoSavedNew() -> Podcast {
        return getFromCoreData() ?? Podcast(podcast: self)
    }
    
    func saveInCoredataIfNotSaved() {
        if getFromCoreData() == nil {
            _ = Podcast(podcast: self)
        }
    }
    
    func getFromCoreData() -> Podcast? {
        return Self.allObjectsFromCoreData.first(matching: id)
    }
    
    func removeFromCoreData() {
        guard let podcast = getFromCoreData() else { return }
        let genres = podcast.genres
        podcast.myValidateDelete()
        saveCoreData()
        guard let genres = genres?.allObjects else { return  }
        genres.forEach { ($0 as! Genre).remove() }
    }
    
    static func removeAllFromCoreData() {
        allObjectsFromCoreData.forEach {
            $0.removeFromCoreData()
        }
    }
}

//MARK: - InputPlayerProtocol
extension Podcast: InputPlayerProtocol {
    
    var genresString: String? {  genres?.allObjects.reduce(into: "") { $0 += (($1 as? Genre)?.name ?? "") + ", " }  }
    var trackTimeMillisString: String? { trackTimeMillis?.minute }
  
    var currentTime: Float? {
        get {
            getListeningPodcast?.currentTime
        }
        set {
            let listeningPodcast = getOrCreateListeningPodcast
            listeningPodcast.currentTime = newValue ?? 0
            saveCoreData()
            listeningPodcast.saveInFireBase()
        }
    }
    
    var progress: Double? {
        get {
            getListeningPodcast?.progress
        }
        set {
            let listeningPodcast = getOrCreateListeningPodcast
            listeningPodcast.progress = newValue ?? 0
            saveCoreData()
            listeningPodcast.saveInFireBase()
        }
    }
    
    var duration: Double? {
        get {
            getListeningPodcast?.duration
        }
        set {
            let listeningPodcast = getOrCreateListeningPodcast
            listeningPodcast.duration = newValue ?? 0
            saveCoreData()
            listeningPodcast.saveInFireBase()
        }
    }
    
    var url: URL? { episodeUrl.url }
    var image600: String? { artworkUrl600 }
    var image160: String? { artworkUrl160 ?? artworkUrl60 }
    var image60: String? { artworkUrl60 }
}

extension Podcast: DownloadServiceProtocol {
    
    var stateOfDownload: StateOfDownload {
        
        if DownloadService.shared.isDownLoad(self) {
            return .isDownload
        }
        
        if DownloadService.shared.isDownloading(self) {
            return .isDownloading
        }
        return .notDownloaded
    }
    
    var downloadUrl: URL? {
        return episodeUrl.url
    }
}

//MARK: - Common
extension Podcast {

    var isFavorite: Bool { getFavoritePodcast() != nil }
    
    var releaseDateInformation: Date? {
        guard let releaseDate = releaseDate else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: releaseDate)
        return date
    }
    
    func formattedDate(dateFormat: String) -> String {
        releaseDateInformation?.formattedDate(dateFormat: dateFormat) ?? ""
    }
    
    /// ListeningPodcast
    private var getOrCreateListeningPodcast: ListeningPodcast {
        return getListeningPodcast ?? ListeningPodcast(podcast: self)
    }
    
    private var getListeningPodcast: ListeningPodcast? {
        return ListeningPodcast.allObjectsFromCoreData.filter { $0.podcast.id == id }.first
    }
    
    /// Favorite
    func addOrRemoveToFavorite() {
        if let favoritePodcast = getFavoritePodcast() {
            favoritePodcast.remove()
        } else {
            _ = FavoritePodcast(podcast: self)
        }
    }
   
    func getFavoritePodcast() -> FavoritePodcast? {
        return FavoritePodcast.allObjectsFromCoreData.filter { $0.podcast.id == id }.first
    }
}
