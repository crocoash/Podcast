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

    convenience init(id: String?, name: String?, viewContext: NSManagedObjectContext? = viewContext) {
        
        self.init(entity: Self.entity(), insertInto: viewContext)
        
        self.id = id
        self.name = name
        
        if viewContext != nil {
            mySave()
        }
    }
    
    /// to viewContext
    required convenience init(_ genre: Genre) {
        
        self.init(entity: Self.entity(), insertInto: Self.viewContext)
        self.id = genre.id
        
        self.name = genre.name
        self.podcasts = genre.podcasts
    }
}

extension Genre: CoreDataProtocol {
    
    var searchId: Int? { Int(id ?? "") }

//    func removeFromCoreDataWithOwnEntityRule() {
//        if let genre = getFromCoreData {
//            genre.myValidateDelete()
//        }
//    }
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

extension Collection where Element: Genre {
    
    func remove(podcast: Podcast) {
        self.forEach {
            $0.removePodcast(podcast: podcast)
            $0.removeFromCoreData()
        }
    }
}
