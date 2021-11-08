//
//  LikedMoment.swift
//  Podcasts
//
//  Created by mac on 08.11.2021.
//

import Foundation
import AVFoundation
import CoreMedia

struct LikedMoment: Codable {
    let podcast: Podcast
    let moment: Double
}
