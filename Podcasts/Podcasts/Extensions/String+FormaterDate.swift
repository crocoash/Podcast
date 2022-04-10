//
//  String+FormaterDate.swift
//  Podcasts
//
//  Created by Anton on 10.04.2022.
//

import Foundation

extension Optional where Wrapped == String {
    
    func formatDate() -> Optional<Wrapped> {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let dateFormatterSet = DateFormatter()
        dateFormatterSet.dateFormat = "MMM d, yyyy"
        
        guard let self = self else {  fatalError("Invalid date in DetailViewController") }
        
        if let date = dateFormatterGet.date(from: self) {
            return dateFormatterSet.string(from: date)
        }
        return nil
    }
}
