//
//  LikedMoment+CoreDataClass.swift
//  Podcasts
//
//  Created by Anton on 15.04.2022.
//
//

import Foundation
import CoreData


public class LikedMoment: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case moment
        case podcast
    }
    
    //MARK: encode
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        moment =    try values.decode(Double .self, forKey: .moment)
        podcast =   try values.decode(Podcast.self, forKey: .podcast)
    }
    
    //MARK: encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(moment, forKey: .moment)
        try container.encode(podcast,forKey: .podcast)
    }
    
    //MARK: init
    convenience init(podcast: Podcast, moment: Double) {
        self.init(entity: Self.entity(), insertInto: Self.viewContext)
        self.moment = moment
        self.podcast = podcast.getFromCoreDataIfNoSavedNew()
        
        saveInit()
    }
}

extension LikedMoment {
    
    static var likedMomentFRC: NSFetchedResultsController<LikedMoment> = {
        let fetchRequest: NSFetchRequest<LikedMoment> = LikedMoment.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(LikedMoment.moment), ascending: true)]
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
            fatalError("Unresolved error \(error), \(nserror.userInfo)")
        }
        return fetchResultController
    }()
    
    var key: String { "\(podcast.id ?? 0)" }
    
    
    static func getLikedMoment(at indexPath: IndexPath) -> LikedMoment {
        return likedMomentFRC.object(at: indexPath)
    }
}


//MARK: - fffffffffff
extension LikedMoment: CoreDataProtocol {
    
    static var allObjectsFromCoreData: [LikedMoment] {
        viewContext.fetchObjects(Self.self)
    }
        
    func getFromCoreDataIfNoSavedNew() -> LikedMoment {
        return getFromCoreData() ?? LikedMoment(podcast: podcast, moment: moment)
    }
    
    func saveInCoredataIfNotSaved() {
        if getFromCoreData() == nil {
            let podcast = podcast
            let moment = moment
            _ = LikedMoment(podcast: podcast, moment: moment)
        }
    }
    
    func getFromCoreData() -> LikedMoment? {
        return Self.allObjectsFromCoreData.filter { $0.podcast.id == id && $0.moment == moment }.first
    }
    
    func removeFromCoreData() {
        guard let likedMoment = getFromCoreData() else { return }
        let podcast = likedMoment.podcast
        remove()
        saveCoreData()
        podcast.remove()
    }
    
    static func removeAllFromCoreData() {
        allObjectsFromCoreData.forEach {
            $0.removeFromCoreData()
        }
    }
}


extension LikedMoment: FirebaseProtocol {
    
    func saveInFireBase() { FirebaseDatabase.shared.add(object: self, key: key)
    }
    
    typealias T = LikedMoment
    
    func removeFromFireBase(key: String) {
        FirebaseDatabase.shared.remove(object: Self.self, key: key)
    }
    
    static func updateFromFireBase(completion: ((Result<[LikedMoment]>) -> Void)?) {
        FirebaseDatabase.shared.update { (result: Result<[LikedMoment]>) in
            switch result {
            case .failure(let error) :
                if error == .noData {
                    removeAllFromCoreData()
                }
            case .success(let moments) :
                
                allObjectsFromCoreData.forEach {
                    if $0.getFromCoreData() != nil {
                        $0.removeFromCoreData()
                    }
                }
                
                moments.forEach {
                    $0.saveInCoredataIfNotSaved()
                }
            }
            completion?(result)
        }
    }
}



