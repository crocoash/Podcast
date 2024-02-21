//
//  String + Localized.swift
//  MovieApp
//
//  Created by Tsvetkov Anton on 31.07.2021.
//

import Foundation

extension String {
  var localized: String { NSLocalizedString(self, comment: "") }
}

extension String {
    func uppercasedFirst() -> String {
        prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
