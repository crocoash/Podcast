//
//  PodcastModel.swift
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
    }
    
    var isDownLoad = false
    var progress: Float = 0
    var index: Int = 0
    var task: URLSessionDownloadTask? = nil
}

