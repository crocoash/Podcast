//
//  Author.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 31.10.2021.
//

import Foundation

struct Author: Codable {
    let wrapperType: String? // artist
    let artistType: String? // Podcast Artist
    let artistName: String? // David Gann
    let artistLinkURL: String? // open in podcast app
    let artistID: Int? // 1214081373
    let primaryGenreName: String? // Podcasts
    let primaryGenreID: Int? //26

    enum CodingKeys: String, CodingKey {
        case wrapperType, artistType, artistName
        case artistLinkURL = "artistLinkUrl"
        case artistID = "artistId"
        case primaryGenreName
        case primaryGenreID = "primaryGenreId"
    }
}
