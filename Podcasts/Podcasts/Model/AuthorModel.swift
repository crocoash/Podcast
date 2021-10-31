//
//  AuthorModel.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 31.10.2021.
//

import Foundation

struct Author: Codable {
    let wrapperType: String?
    let artistType: String?
    let artistName: String?
    let artistLinkURL: String?
    let artistID: Int?
    let primaryGenreName: String?
    let primaryGenreID: Int?

    enum CodingKeys: String, CodingKey {
        case wrapperType, artistType, artistName
        case artistLinkURL = "artistLinkUrl"
        case artistID = "artistId"
        case primaryGenreName
        case primaryGenreID = "primaryGenreId"
    }
}
