//
//  Author+CoreDataClass.swift
//  
//
//  Created by Tsvetkov Anton on 19.03.2022.
//
//

import Foundation
import CoreData


//@objc(Author)
public class Author: NSManagedObject, Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case artistID = "artistId"
        case artistLinkURL = "artistLinkUrl"
        case artistName, artistType
    }
    
    required convenience public init(from decoder: Decoder) throws {
        
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            fatalError("mistake")
        }
        
        let entity = NSEntityDescription.entity(forEntityName: "Author", in: context)!
        self.init(entity: entity, insertInto: context)
//        self.init(context: context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        artistID = try values.decode(Int32.self, forKey: .artistID)
        artistLinkURL = try values.decode(String.self, forKey: .artistLinkURL)
        artistName = try values.decode(String.self, forKey: .artistName)
        artistType = try values.decode(String.self, forKey: .artistType)
    }
}


