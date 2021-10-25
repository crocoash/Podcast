//
//  PodcastModel.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 25.10.2021.
//

import Foundation

// MARK: - Result
struct Podcast: Codable {
    let previewURL: String?
    let episodeFileExtension: String?
    let artworkUrl160: String?
    let episodeContentType: String?
    let artworkUrl600, artworkUrl60: String?
    let artistViewURL: String?
    let contentAdvisoryRating: String?
    let trackViewURL: String?
    let trackTimeMillis: Int?
    let collectionViewURL: String?
    let episodeURL: String?
    let collectionID: Int?
    let collectionName: String?
    let trackID: Int?
    let trackName: String?
    let releaseDate: String?
    let shortDescription: String?
    let feedURL: String?
    let artistIDS: [Int]?
    let closedCaptioning, country, resultDescription: String?
    let episodeGUID, kind, wrapperType: String?
}
