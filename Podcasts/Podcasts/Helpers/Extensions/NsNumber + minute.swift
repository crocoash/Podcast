//
//  NsNumber + minute.swift
//  Podcasts
//
//  Created by Anton on 15.04.2023.
//

import Foundation

extension NSNumber {
    var minute: String {
        String((self.intValue / 1000) / 60) + " min"
    }
}
