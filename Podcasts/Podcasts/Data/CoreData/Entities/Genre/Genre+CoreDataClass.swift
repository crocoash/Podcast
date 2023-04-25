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
    /// to nil
    convenience init(id: String?, name: String?) {
        
        self.init(entity: Self.entity(), insertInto: nil)
        
        self.id = id
        self.name = name
    }
    
    /// to viewContext
    convenience init(genre: Genre) {
        
        self.init(entity: Self.entity(), insertInto: Self.viewContext)
        
        self.id = genre.id
        self.name = genre.name
        self.podcasts = genre.podcasts
        
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

    func removeFromCoreDataWithOwnEntityRule() {
        if let genre = getFromCoreData {
            genre.myValidateDelete()
        }
    }
    
    func saveInCoredataIfNotSaved() {
        if let _ = getFromCoreData  { _ = Genre(genre: self) }
    }
   
    var getFromCoreData: Genre? {
        return Self.allObjectsFromCoreData.first(matching: self)
    }
    
    var getFromCoreDataIfNoSavedNew: Genre {
        return Self.allObjectsFromCoreData.first(matching: self) ?? Genre(genre: self)
    }
}

//MARK: - Common
extension Genre {
    
    func removePodcast(podcast: Podcast) {
        if let podcasts = self.podcasts?.allObjects as? [Podcast] {
            let podcasts = podcasts.filter { $0 != podcast }
            self.podcasts = NSSet(array: podcasts)
        }
    }
}
