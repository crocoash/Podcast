//
//  URL + localPath.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 08.11.2021.
//

import Foundation

extension URL {
    
    var locaPath: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent(self.lastPathComponent)
    }
}
