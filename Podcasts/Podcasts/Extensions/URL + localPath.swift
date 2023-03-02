//
//  URL + localPath.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 08.11.2021.
//

import Foundation

extension URL {
    
    var localPath: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(self.lastPathComponent)
    }
    
    var isDownLoad: Bool {
        FileManager.default.fileExists(atPath: self.path)
    }
}

