//
//  Podcast.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 25.10.2021.
//


import Foundation

// MARK: - Result
struct Podcast: Codable, Equatable, Identifiable {
    
    let previewUrl: String? //podcast
    let episodeFileExtension: String? //mp3
    let artworkUrl160: String? // photo of podcast
    let episodeContentType: String? // audio
    let artworkUrl600: String? // photo of podcast
    let artworkUrl60: String? //  photo :)
    let artistViewUrl: String? // podcast in podcast url
    let contentAdvisoryRating: String? //Explicit
    let trackViewUrl: String? // podcast in browser
    let trackTimeMillis: Int? // 8086000
    let collectionViewUrl: String? // collection in browser
    let episodeUrl: String? // podcast with episode small
    let collectionId: Int? // 1236778275
    let collectionName: String? // VIEWS with David Dobrik & Jason Nash
    let id: Int?
    let trackName: String? // David and Natalie Discuss their Relationship
    let releaseDate: String? // 2019-11-09T22:14:13Z
    let shortDescription: String? //
    let feedUrl: String? // feedburner.com
    let artistIds: [Int]?  //[1310874139]
    let closedCaptioning: String? // none
    let country: String? // USA
    let description: String? // text
    let episodeGuid: String? // 69fa220d-ba11-4238-a1f8-a87038fee528
    let kind : String? // podcast-episode
    let wrapperType: String? // podcastEpisode
    
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
        case shortDescription
        case feedUrl
        case artistIds
        case closedCaptioning
        case country
        case description
        case episodeGuid
        case kind
        case wrapperType
        case isDownLoad
        case progress
        case index
    }
    
    var isDownLoad: Bool
    var progress: Float
    var index: Int?
    var task: URLSessionDownloadTask? = nil
    
    init(from decoder: Decoder) throws {
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
        trackTimeMillis = container.contains(.trackTimeMillis) ? try container.decode(Int.self, forKey: .trackTimeMillis) : nil
        collectionViewUrl = container.contains(.collectionViewUrl) ? try container.decode(String.self, forKey: .collectionViewUrl) : nil
        episodeUrl = container.contains(.episodeUrl) ? try container.decode(String?.self, forKey: .episodeUrl) : nil
        collectionId = container.contains(.collectionId) ? try container.decode(Int?.self, forKey: .collectionId) : nil
        collectionName = container.contains(.collectionName) ? try container.decode(String?.self, forKey: .collectionName) : nil
        id = container.contains(.id) ? try container.decode(Int?.self, forKey: .id) : nil
        trackName = container.contains(.trackName) ? try container.decode(String?.self, forKey: .trackName) : nil
        releaseDate = container.contains(.releaseDate) ? try container.decode(String?.self, forKey: .releaseDate) : nil
        shortDescription = container.contains(.shortDescription) ? try container.decode(String?.self, forKey: .shortDescription) : nil
        feedUrl = container.contains(.feedUrl) ? try container.decode(String?.self, forKey: .feedUrl) : nil
        artistIds = container.contains(.artistIds) ? try container.decode([Int]?.self, forKey: .artistIds) : nil
        closedCaptioning = container.contains(.closedCaptioning) ? try container.decode(String?.self, forKey: .closedCaptioning) : nil
        country = container.contains(.country) ? try container.decode(String?.self, forKey: .country) : nil
        description = container.contains(.description) ? try container.decode(String?.self, forKey: .description) : nil
        episodeGuid = container.contains(.episodeGuid) ? try container.decode(String?.self, forKey: .episodeGuid) : nil
        kind = container.contains(.kind) ? try container.decode(String?.self, forKey: .kind) : nil
        wrapperType = container.contains(.wrapperType) ? try container.decode(String?.self, forKey: .wrapperType) : nil
        
        isDownLoad = container.contains(.isDownLoad) ? try container.decode(Bool.self, forKey: .isDownLoad) : false
        progress = container.contains(.progress) ? try container.decode(Float.self, forKey: .progress) : 0
        index = container.contains(.index) ? try container.decode(Int?.self, forKey: .index) : nil
    }
}
