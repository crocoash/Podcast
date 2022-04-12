//
//  Collection + Match.swift
//  MovieApp
//
//  Created by Tsvetkov Anton on 18.07.2021.
//

import SwiftUI

extension Collection where Element: Identifiable {
    
    func firstIndex(matching element: Element) -> Self.Index? {
        return firstIndex { $0.id == element.id }
    }
    
    func firstIndex(matching id: Element.ID) -> Self.Index? {
        return firstIndex { $0.id == id }
    }
    
    func firstIndex(matching id: Element.ID?) -> Bool {
        guard let id = id else { return false }
        
        for item in self {
            if item.id == id {
                return true
            }
        }
        return false
    }
    
    func firstPodcast(matching id: Element.ID?) -> Element? {
        guard let id = id else { return nil }
        
        for item in self {
            if item.id == id {
                return item
            }
        }
        return nil
    }
    
}




