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

extension Optional where Wrapped == URL {
    
    var isDownload: Bool {
        if let self = self {
            return self.isDownLoad
        }
        return false
    }
    
    var localPath: URL? {
        if let self = self {
            return self.localPath
        }
        return nil
    }
}

