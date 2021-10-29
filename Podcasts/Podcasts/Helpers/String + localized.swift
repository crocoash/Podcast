//
//  String + localized.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 26.10.2021.
//

import Foundation

extension String {
  var localized: String { NSLocalizedString(self, comment: "") }
}
