//
//  Genre+CoreDataClass.swift
//  Podcasts
//
//  Created by Anton on 13.02.2023.
//
//

import Foundation
import CoreData

@objc(Genre)
public class Genre: NSManagedObject, Codable {
    private enum CodingKeys: String, CodingKey {
        case id, name
    }
    
    //MARK: decoder
    required convenience public init(from decoder: Decoder) throws {
        self.init(entity: Self.entity(), insertInto: nil)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
    }
    
    //MARK: encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name,forKey: .name)
    }
    
    //MARK: init
    convenience init(id: String?, name: String?) {
        
        self.init(entity: Self.entity(), insertInto: nil)
        self.id = id
        self.name = name
    }
    
    convenience init(genre: Genre) {
        
        self.init(entity: Self.entity(), insertInto: Self.viewContext)
        self.id = id
        self.name = name
        
        saveInit()
    }
}

extension Genre: CoreDataProtocol {
    
    typealias T = Genre
    
    static var allObjectsFromCoreData: [Genre] { viewContext.fetchObjects(Genre.self) }
    
    static func removeAll() {
        allObjectsFromCoreData.forEach {
            $0.remove()
        }
    }

    func removeFromCoreData() {
        if let genre = getFromCoreData() {
            genre.myValidateDelete()
        }
    }
    
    func saveInCoredataIfNotSaved() {
        if getFromCoreData() == nil { _ = Genre(genre: self) }
    }
    
    func getFromCoreData() -> Genre? {
        return Self.allObjectsFromCoreData.first(matching: self)
    }
    
    func getFromCoreDataIfNoSavedNew() -> Genre {
        return Self.allObjectsFromCoreData.first(matching: self) ?? Genre(genre: self)
    }
    
    static func removeAllFromCoreData() {
        allObjectsFromCoreData.forEach {
            $0.removeFromCoreData()
        }
    }
}
