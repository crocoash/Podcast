//
//  FirebaseDataBase.swift
//  Podcasts
//
//  Created by Anton on 23.04.2022.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import CoreData

protocol FirebaseDatabaseDelegate: AnyObject {
  func firebaseDatabaseDidGetData(_ firebaseDatabase: FirebaseDatabase)
}

class FirebaseDatabase {
  
  static var shared = FirebaseDatabase()
  private init() {}
  
  weak var delegate: FirebaseDatabaseDelegate?
  
  private var ref = Database.database(url: "https://podcast-app-8fcd2-default-rtdb.europe-west1.firebasedatabase.app").reference()
  private let userID = Auth.auth().currentUser!.uid
  private let viewContext = DataStoreManager.shared.viewContext
  private lazy var favoritePodcasts = ref.child("FavoritePodcasts").child(userID)
  
  func save() {
    guard let podcasts = try? DataStoreManager.shared.viewContext.fetch(Podcast.fetchRequest()) else { return }
    if let podcastData = try? JSONEncoder().encode(podcasts) {
      if let serialization = try? JSONSerialization.jsonObject(with: podcastData, options: .allowFragments) as? [Dictionary<String, Any>] {
        favoritePodcasts.setValue(serialization)
      }
    }
  }
  
  func getPodcast(completion: @escaping () -> Void) {
    favoritePodcasts.getData { [weak self] error, snapShot in
      self?.obtain(type: Podcast.self, snapshot: snapShot) { podcasts in
        podcasts.forEach {
          _ = Podcast(podcast: $0)
        }
        completion()
      }
    }
  }
  
  func observe() {
    favoritePodcasts.observe(.value) { [weak self] snapShot in
      self?.obtain(type: Podcast.self, snapshot: snapShot) { podcasts in
        podcasts.forEach {
          _ = Podcast(podcast: $0)
        }
      }
    }
  }
}

extension FirebaseDatabase {
  private func obtain<T: Codable>(type: T.Type, snapshot: DataSnapshot, completion: @escaping ([T]) -> Void) where T: NSManagedObject {
    guard let value = snapshot.value else { return }
    
    DataStoreManager.shared.removeAll(fetchRequest: NSFetchRequest<T>(entityName: type.description()))
    
    if let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) {
      do {
        let result = try JSONDecoder(context: self.viewContext).decode([T].self, from: data)
        completion(result)
        self.viewContext.mySave()
      } catch let error {
        print(error)
      }
    }
    self.delegate?.firebaseDatabaseDidGetData(self)
  }
}





