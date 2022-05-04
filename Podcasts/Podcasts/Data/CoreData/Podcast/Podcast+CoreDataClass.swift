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
    case progress
  }
  
  required convenience public init(from decoder: Decoder) throws {
    
    guard let context = decoder.userInfo[.context] as? NSManagedObjectContext,
          let entity = NSEntityDescription.entity(forEntityName: Podcast.description(), in: context)
    else { fatalError("mistake") }
    
    self.init(entity: entity, insertInto: nil)

    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    previewUrl =            try container.decodeIfPresent(String.self, forKey: .previewUrl)
    episodeFileExtension =  try container.decodeIfPresent(String.self, forKey: .episodeFileExtension)
    artworkUrl160 =         try container.decodeIfPresent(String.self, forKey: .artworkUrl160)
    episodeContentType =    try container.decodeIfPresent(String.self, forKey: .episodeContentType)
    artworkUrl600 =         try container.decodeIfPresent(String.self, forKey: .artworkUrl600)
    artworkUrl60 =          try container.decodeIfPresent(String.self, forKey: .artworkUrl60)
    artistViewUrl =         try container.decodeIfPresent(String.self, forKey: .artistViewUrl)
    contentAdvisoryRating = try container.decodeIfPresent(String.self, forKey: .contentAdvisoryRating)
    trackViewUrl =          try container.decodeIfPresent(String.self, forKey: .trackViewUrl)
    trackTimeMillis =       try container.decodeIfPresent(Int   .self, forKey: .trackTimeMillis) as? NSNumber
    collectionViewUrl =     try container.decodeIfPresent(String.self, forKey: .collectionViewUrl)
    episodeUrl =            try container.decodeIfPresent(String.self, forKey: .episodeUrl)
    collectionId =          try container.decodeIfPresent(Int   .self, forKey: .collectionId) as? NSNumber
    collectionName =        try container.decodeIfPresent(String.self, forKey: .collectionName)
    id =                    try container.decodeIfPresent(Int   .self, forKey: .id) as? NSNumber
    trackName =             try container.decodeIfPresent(String.self, forKey: .trackName)
    releaseDate =           try container.decodeIfPresent(String.self, forKey: .releaseDate)
    shortDescriptionMy =    try container.decodeIfPresent(String.self, forKey: .shortDescriptionMy)
    feedUrl =               try container.decodeIfPresent(String.self, forKey: .feedUrl)
    artistIds =             try container.decodeIfPresent([Int] .self, forKey: .artistIds)
    closedCaptioning =      try container.decodeIfPresent(String.self, forKey: .closedCaptioning)
    country =               try container.decodeIfPresent(String.self, forKey: .country)
    descriptionMy =         try container.decodeIfPresent(String.self, forKey: .descriptionMy)
    episodeGuid =           try container.decodeIfPresent(String.self, forKey: .episodeGuid)
    kind =                  try container.decodeIfPresent(String.self, forKey: .kind)
    wrapperType =           try container.decodeIfPresent(String.self, forKey: .wrapperType)
  }

  convenience init(podcast: Podcast) {
    let viewContext = DataStoreManager.shared.viewContext

    guard let entity = NSEntityDescription.entity(forEntityName: "Podcast", in: viewContext) else { fatalError() }
    
    self.init(entity: entity, insertInto: viewContext)
    
    self.previewUrl =             podcast.previewUrl
    self.episodeFileExtension =   podcast.episodeFileExtension
    self.artworkUrl160 =          podcast.artworkUrl160
    self.episodeContentType =     podcast.episodeContentType
    self.artworkUrl600 =          podcast.artworkUrl600
    self.artworkUrl60 =           podcast.artworkUrl60
    self.artistViewUrl =          podcast.artistViewUrl
    self.contentAdvisoryRating =  podcast.contentAdvisoryRating
    self.trackViewUrl =           podcast.trackViewUrl
    self.trackTimeMillis =        podcast.trackTimeMillis
    self.collectionViewUrl =      podcast.collectionViewUrl
    self.episodeUrl =             podcast.episodeUrl
    self.collectionId =           podcast.collectionId
    self.collectionName =         podcast.collectionName
    self.id =                     podcast.id
    self.trackName =              podcast.trackName
    self.releaseDate =            podcast.releaseDate
    self.shortDescriptionMy =     podcast.shortDescriptionMy
    self.feedUrl =                podcast.feedUrl
    self.artistIds =              podcast.artistIds
    self.closedCaptioning =       podcast.closedCaptioning
    self.country =                podcast.country
    self.descriptionMy =          podcast.descriptionMy
    self.episodeGuid =            podcast.episodeGuid
    self.kind =                   podcast.kind
    self.wrapperType =            podcast.wrapperType
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(previewUrl,                forKey: .previewUrl)
    try container.encode(episodeFileExtension,      forKey: .episodeFileExtension)
    try container.encode(artworkUrl160,             forKey: .artworkUrl160)
    try container.encode(episodeContentType,        forKey: .episodeContentType)
    try container.encode(artworkUrl600,             forKey: .artworkUrl600)
    try container.encode(artworkUrl60,              forKey: .artworkUrl60)
    try container.encode(artistViewUrl,             forKey: .artistViewUrl)
    try container.encode(contentAdvisoryRating,     forKey: .contentAdvisoryRating)
    try container.encode(trackViewUrl,              forKey: .trackViewUrl)
    try container.encode(trackTimeMillis?.intValue, forKey: .trackTimeMillis)
    try container.encode(collectionViewUrl,         forKey: .collectionViewUrl)
    try container.encode(episodeUrl,                forKey: .episodeUrl)
    try container.encode(collectionId?.intValue,    forKey: .collectionId)
    try container.encode(collectionName,            forKey: .collectionName)
    try container.encode(id?.intValue,              forKey: .id)
    try container.encode(trackName,                 forKey: .trackName)
    try container.encode(releaseDate,               forKey: .releaseDate)
    try container.encode(shortDescriptionMy,        forKey: .shortDescriptionMy)
    try container.encode(feedUrl,                   forKey: .feedUrl)
    try container.encode(artistIds,                 forKey: .artistIds)
    try container.encode(closedCaptioning,          forKey: .closedCaptioning)
    try container.encode(country,                   forKey: .country)
    try container.encode(descriptionMy,             forKey: .descriptionMy)
    try container.encode(episodeGuid,               forKey: .episodeGuid)
    try container.encode(kind,                      forKey: .kind)
    try container.encode(wrapperType,               forKey: .wrapperType)
  }
}

extension Podcast {
  
  static private var viewContext = DataStoreManager.shared.viewContext 
  
  static func getOrCreatePodcast(podcast: Podcast) -> Podcast {
    if let podcasts = try? viewContext.fetch(Podcast.fetchRequest()) {
      if let findsavePodcast = podcasts.first(matching: podcast.id) {
        return findsavePodcast
      }
    }
    let newPodcast = Podcast(podcast: podcast)
    viewContext.mySave()
    return newPodcast
  }
}
