//
//  ListeningPodcast+CoreDataClass.swift
//  Podcasts
//
//  Created by Anton on 11.02.2023.
//
//

import Foundation
import CoreData

@objc(ListeningPodcast)
public class ListeningPodcast: NSManagedObject, Codable {
    
    
    private enum CodingKeys: String, CodingKey {
        case currentTime
        case duration
        case progress
        case podcast
    }
    
    ///decoder
    required convenience public init(from decoder: Decoder) throws {
        
        self.init(entity: Self.entity(), insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        currentTime = try container.decode(Float.self, forKey: .currentTime)
        duration =    try container.decode(Double.self, forKey: .duration)
        progress =    try container.decode(Double.self, forKey: .progress)
        podcast =     try container.decode(Podcast.self, forKey: .podcast)
    }
    
    ///encode
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(currentTime,                      forKey: .currentTime)
        try container.encode(duration,                      forKey: .duration)
        try container.encode(progress,                      forKey: .progress)
        try container.encode(podcast,                      forKey: .podcast)
    }
    
    ///init
    convenience init(podcast: Podcast) {
        
        self.init(entity: Self.entity(), insertInto: Self.viewContext)
        
        self.currentTime = 0
        self.duration = 0
        self.progress = 0
        self.podcast = podcast.getFromCoreDataIfNoSavedNew()
        
        saveInit()
    }
}

extension ListeningPodcast: CoreDataProtocol {
    
    typealias T = ListeningPodcast
    
    static var allObjectsFromCoreData: [ListeningPodcast] {
        return Self.viewContext.fetchObjects(Self.self)
    }
    
    func removeFromCoreData() {
        if let listeningPodcast = getFromCoreData() {
            let podcast = listeningPodcast.podcast
            Self.viewContext.delete(listeningPodcast)
            saveCoreData()
            podcast.removeFromCoreData()
        }
    }
    
    func saveInCoredataIfNotSaved() {
        if getFromCoreData() == nil {
            _ = ListeningPodcast(podcast: podcast)
        }
    }
    
    func getFromCoreData() -> ListeningPodcast? {
        return Self.allObjectsFromCoreData.first(matching: self)
    }
    
    func getFromCoreDataIfNoSavedNew() -> ListeningPodcast {
        return  getFromCoreData() ?? ListeningPodcast(podcast: podcast)
    }
    
    static func removeAllFromCoreData() {
        Self.allObjectsFromCoreData.forEach {
            $0.removeFromCoreData()
        }
    }
}

extension ListeningPodcast: FirebaseProtocol {
    
    var key: String { "\(podcast.id ?? 0)" }
    
    func removeFromFireBase(key: String) {
        FirebaseDatabase.shared.remove(object: Self.self, key: key)
    }
    
    func saveInFireBase() {
        FirebaseDatabase.shared.add(object: self, key: key)
    }
    
    static func updateFromFireBase(completion: ((Result<[ListeningPodcast]>) -> Void)?) {
        FirebaseDatabase.shared.update { (result: Result<[ListeningPodcast]>) in
            switch result {
            case .failure(let error) :
                if error == .noData {
                    removeAllFromCoreData()
                }
            case .success(let entities) :
                update(by: entities)
            }
            completion?(result)
        }
    }
    
    
    static func update(by entities: [ListeningPodcast]) {
        Self.allObjectsFromCoreData.forEach { entity in
            if !entities.contains(where: { $0.id == entity.id }) {
                entity.removeFromCoreData()
            }
        }
        
        entities.forEach { entity in
            entity.saveInCoredataIfNotSaved()
        }
    }
}
