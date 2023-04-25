//
//  FavoritePodcast+CoreDataClass.swift
//  Podcasts
//
//  Created by Anton on 03.05.2022.
//
//

import UIKit
import CoreData

//protocol



public class FavoritePodcast: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case podcast
        case date
        case id
    }
    
    required convenience public init(from decoder: Decoder) throws {
        self.init(entity: Self.entity(), insertInto: nil)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        podcast = try values.decode(Podcast.self, forKey: .podcast)
        date = try values.decode(Date.self, forKey: .date)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(podcast,forKey: .podcast)
        try container.encode(date,forKey: .date)
    }
    
    convenience init(podcast: Podcast) {
        
        self.init(entity: Self.entity(), insertInto: Self.viewContext)
        
        self.podcast = podcast.getFromCoreDataIfNoSavedNew
        self.date = Date()
        
        saveInit()
    }
}


//MARK: - CoreDataProtocol
extension FavoritePodcast: CoreDataProtocol {
    
    typealias T = FavoritePodcast
    
    static var allObjectsFromCoreData: [FavoritePodcast] { fetchResultController.fetchedObjects ?? [] }
    
    
    func removeFromCoreDataWithOwnEntityRule() {
        guard let favoritePodcast = getFromCoreData else { return }
        let podcast = favoritePodcast.podcast
        favoritePodcast.removeFromViewContext()
        podcast.remove()
    }
  
    func saveInCoredataIfNotSaved() {
        if getFromCoreData == nil {  _ = FavoritePodcast(podcast: podcast) }
    }
    
    static func removeAll() {
        allObjectsFromCoreData.forEach {
            $0.remove()
        }
    }
    
    var getFromCoreData: FavoritePodcast? {
        Self.allObjectsFromCoreData.filter { $0.podcast.id == podcast.id }.first
    }
    
    var getFromCoreDataIfNoSavedNew: FavoritePodcast {
        return getFromCoreData ?? FavoritePodcast(podcast: podcast)
    }
}

extension FavoritePodcast: NsManagedTableViewProtocol {
    static var fetchResultController: NSFetchedResultsController<FavoritePodcast> = {
        let fetchRequest = FavoritePodcast.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(FavoritePodcast.date), ascending: true)]
        
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchResultController.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return fetchResultController
    }()
    
    static func getObject(by indexPath: IndexPath) -> FavoritePodcast {
        return fetchResultController.object(at: indexPath)
    }
    
    static func getIndexPath(id: NSNumber?) -> IndexPath? {
        guard let id = id else { return nil }
        let fetchRequest = FavoritePodcast.fetchRequest()
        let predicate = NSPredicate(format: "podcast.id == %@", id)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        if let favoritePodcast = try? viewContext.fetch(fetchRequest).first {
            return favoritePodcast.getIndexPath
        }
        return nil
    }
    
    var getIndexPath: IndexPath? {
        return Self.fetchResultController.indexPath(forObject: self)
    }
}

//MARK: - FirebaseProtocol
extension FavoritePodcast: FirebaseProtocol {
    
    var key: String { "\(podcast.id ?? 0)" }
    
    func saveInFireBase() {
        FirebaseDatabase.shared.add(object: self, key: key)
    }
    
    func removeFromFireBase(key: String) {
        FirebaseDatabase.shared.remove(object: Self.self, key: key)
    }
    
    static func updateFromFireBase(completion: ((Result<[FavoritePodcast]>) -> Void)?) {
        FirebaseDatabase.shared.update {  (result: Result<[FavoritePodcast]>) in
            switch result {
            case .failure(let error) :
                if error == .noData {
                    Self.removeAll()
                    return
                }
            case .success(let podcastsFromFireBase) :
                Self.updateFavoritePodcast(by: podcastsFromFireBase)
            }
            completion?(result)
        }
    }
    
    ///???????
    static func updateFavoritePodcast(by podcastsFromFireBase: [FavoritePodcast]) {
        for favoritePodcast in Self.allObjectsFromCoreData {
            if !podcastsFromFireBase.contains(where: { $0.podcast.id == favoritePodcast.podcast.id }) {
                favoritePodcast.remove()
            }
        }
        
        podcastsFromFireBase.forEach { favoritePodcast in
            favoritePodcast.saveInCoredataIfNotSaved()
        }
    }
}


class BasicFireBaseClass<S>  where S: NSManagedObject & Identifiable {
    
    var test: String { S.entityName + "r"}
    
}



