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
        return self.contains { $0.id == id}
    }
    
    func firstPodcast(matching id: Element.ID?) -> Element? {
        return self.filter { $0.id == id }.first
    }
}




