//
//  String + comform.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 01.11.2021.
//

import Foundation

extension String {
    var conform: String {
        return String(self.map { $0 == " " ? "-" : $0 })
    }
}
