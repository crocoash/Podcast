//
//  Dictionary.swift
//  Podcasts
//
//  Created by Anton on 15.04.2023.
//

import Foundation

extension Dictionary {
    
    var arrayOfKeys: [Self.Key] {
        return Array(self.keys)
    }
    
    var arrayOfValues: [Self.Value] {
        return Array(self.values)
    }
}
