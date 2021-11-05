//
//  String + comform.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 01.11.2021.
//

// FIXME: Именование метода непоятное

import Foundation

extension String {
    var conform: String {
        String(self.map { $0 == " " ? "-" : $0 })
    }
}
