//
//  Collection + Match.swift
//  MovieApp
//
//  Created by Tsvetkov Anton on 18.07.2021.
//

import Foundation

extension Collection where Element: Identifiable {
    
    func firstIndex(matching element: Element) -> Self.Index? {
        return firstIndex { $0.id == element.id }
    }
    
    func firstIndex(matching id: Element.ID) -> Self.Index? {
        return firstIndex { $0.id == id }
    }
    
    func firstIndex(matching id: Element.ID?) -> Bool {
        return self.contains { $0.id == id }
    }
    
    func first(matching id: Element.ID?) -> Element? {
        return self.filter { $0.id == id }.first
    }
    
    func first(matching element: Element) -> Element? {
        return self.filter { $0.id == element.id }.first
    }
}

extension Collection {
    
    var count: CGFloat {
        
        return CGFloat(self.count)
    }
}

extension Collection {
   
    func enumerated(_ completion: (Int, Element) async -> Void) async {
        for (index, value) in self.enumerated() {
            await completion(index, value)
        }
    }
    
    func enumerated(_ completion: (Int, Element) -> Void) {
        for (index, value) in self.enumerated() {
            completion(index, value)
        }
    }
    
    func forEach(_ body:  (Element) async -> Void) async {
        for i in self {
           await body(i)
        }
    }
}