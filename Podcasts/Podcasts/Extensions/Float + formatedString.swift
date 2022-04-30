//
//  Float + formatedString.swift
//  Podcasts
//
//  Created by Anton on 30.04.2022.
//

import Foundation

extension Float {
    var formattedString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional

        guard let formattedString = formatter.string(from: TimeInterval(self)) else { return "0:0"}
        
        switch formattedString.count {
        case 0..<2:
            return "0:0\(formattedString)"
        case 2..<4:
            return "0:\(formattedString)"
        default:
            return formattedString
        }
    }
}
