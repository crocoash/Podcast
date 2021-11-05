//
//  Collection + Match.swift
//  MovieApp
//
//  Created by Tsvetkov Anton on 18.07.2021.
//

// FIXME: Название файла просто Collection. Нужно сделать по аналогии с другими

import SwiftUI

extension Collection where Element: Identifiable {
    
    func firstIndex(matching element: Element) -> Self.Index? {
        firstIndex { $0.id == element.id }
    }
    
    func firstIndex(matching id: Element.ID) -> Self.Index? {
        firstIndex { $0.id == id }
    }
    
    func firstIndex(matching id: Element.ID?) -> Bool {
        guard id != nil else { return false }
        for item in self {
            return item.id == id
        }
        return false
    }
}




