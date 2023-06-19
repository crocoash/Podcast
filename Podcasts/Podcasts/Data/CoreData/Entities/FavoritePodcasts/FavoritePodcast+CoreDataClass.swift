//
//  FavoritePodcast+CoreDataClass.swift
//  Podcasts
//
//  Created by Anton on 03.05.2022.
//
//

import UIKit
import CoreData


public class FavoritePodcast: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case podcast
        case date
        case identifier
    }
    
    //MARK: decoder
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        podcast = try values.decode(Podcast.self, forKey: .podcast)
        date = try values.decode(Date.self, forKey: .date)
        identifier = try values.decode(String.self, forKey: .identifier)
    }
    
    //MARK: encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(podcast, forKey: .podcast)
        try container.encode(date, forKey: .date)
        try container.encode(identifier, forKey: .identifier)
    }
    
    @discardableResult
    convenience init(podcast: Podcast) {
        self.init(entity: Self.entity(), insertInto: Self.viewContext)
        print("print init podcast")
        self.date = Date()
        self.podcast = podcast.getFromCoreDataIfNoSavedNew
        self.identifier = UUID().uuidString
        
        mySave()
    }

    ///init to viewContext
    @discardableResult
    required convenience init(_ favoritePodcast: FavoritePodcast) {
        
        self.init(entity: Self.entity(), insertInto: Self.viewContext)
        
        self.date = favoritePodcast.date
        self.podcast = favoritePodcast.podcast.getFromCoreDataIfNoSavedNew
        self.identifier = favoritePodcast.identifier
    }
    
    ///init to viewContext
    @discardableResult
    required convenience init(_ favoritePodcast: FavoritePodcast, viewContext: NSManagedObjectContext) {
        
        self.init(entity: Self.entity(), insertInto: viewContext)
        
            self.date = favoritePodcast.date
            self.podcast = favoritePodcast.podcast.getFromCoreDataIfNoSavedNew
            self.identifier = favoritePodcast.identifier
        
        mySave()
    }
}

//MARK: - CoreDataProtocol
extension FavoritePodcast: CoreDataProtocol { }

extension FavoritePodcast {
    
    static func fetchResultController(
        sortDescription: [NSSortDescriptor] = [NSSortDescriptor(key: #keyPath(podcast.trackName),ascending: true)],
        predicates: [NSPredicate]? = nil,
        sectionNameKeyPath: String? = nil,
        fetchLimit: Int? = nil
    ) -> NSFetchedResultsController<FavoritePodcast> {
        
        let fetchRequest: NSFetchRequest<FavoritePodcast> = FavoritePodcast.fetchRequest()
        
        
        if let predicates = predicates {
            for predicate in predicates {
                fetchRequest.predicate = predicate
            }
        }
        
        fetchRequest.fetchLimit = fetchLimit ?? Int.max
//        fetchRequest.fetchLimit = 3
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = sortDescription
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil
        )
        
        do {
            try fetchResultController.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(error), \(nserror.userInfo)")
        }
        return fetchResultController
    }
    
    static func getObject(by indexPath: IndexPath) -> FavoritePodcast {
        return fetchResultController().object(at: indexPath)
    }
    
//    static func getIndexPath(identifier: String) -> IndexPath? {
//        let fetchRequest = FavoritePodcast.fetchRequest()
//        let predicate = NSPredicate(format: "podcast.identifier == %@", identifier)
//        fetchRequest.predicate = predicate
//        fetchRequest.fetchLimit = 1
//        
//        if let favoritePodcast = try? viewContext.fetch(fetchRequest).first {
//            return favoritePodcast.getIndexPath
//        }
//        return nil
//    }
    
//    //TODO: - check
//    var getIndexPath: IndexPath? {
//        return Self.fetchResultController().indexPath(forObject: self)
//    }
}

//MARK: - FirebaseProtocol
extension FavoritePodcast: FirebaseProtocol { }

//extension FavoritePodcast: DownloadProtocol {
//    var downloadUrl: String? {
//        podcast.downloadUrl
//    }
//}
