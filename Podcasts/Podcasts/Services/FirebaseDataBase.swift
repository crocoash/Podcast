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
  
  private let userID = Auth.auth().currentUser!.uid
  private var viewContext: NSManagedObjectContext { DataStoreManager.shared.viewContext }
  
  private var ref = Database.database(url: "https://podcast-app-8fcd2-default-rtdb.europe-west1.firebasedatabase.app").reference()
  lazy private var userStorage = ref.child(userID)
  lazy private var favoritePodcastsPath = userStorage.child("FavoritePodcasts")
  lazy private var likedPodcastsPath = userStorage.child("LikedPodcasts")
  
  func savePodcast() {
    save(type: FavoritePodcast.self) {
      favoritePodcastsPath.setValue($0)
//      favoritePodcastsPath.child("0").setNilValueForKey("idd")
//      favoritePodcastsPath.
    }
  }
  
  func saveLikedMoment() {
    save(type: LikedMoment.self) {
      likedPodcastsPath.setValue($0)
    }
  }
  
  func observe() {
    userStorage.observe(.value) { [weak self] snapShot in

      let favoriteSnapShot = snapShot.childSnapshot(forPath: "FavoritePodcasts")
      let likedSnapShot = snapShot.childSnapshot(forPath: "LikedPodcasts")

      guard let self = self else { return }

      self.obtain(type: FavoritePodcast.self, snapshot: favoriteSnapShot) {
        $0.forEach {
          _ = FavoritePodcast.getOrCreateFavoritePodcast($0)
          self.viewContext.mySave()
        }
      }
      
      self.obtain(type: LikedMoment.self, snapshot: likedSnapShot) {
        $0.forEach {
          let podcast = Podcast.getOrCreatePodcast(podcast: $0.podcast)
          _ = LikedMoment(podcast: podcast, moment: $0.moment)
          self.viewContext.mySave()
        }
      }
      self.delegate?.firebaseDatabaseDidGetData(self)
    }
  }
  
  func getFavoritePodcast(completion: @escaping () -> Void) {
    favoritePodcastsPath.getData { [weak self] error, snapShot in
      let favoriteSnapShot = snapShot.childSnapshot(forPath: "FavoritePodcasts")
      guard error == nil,
            let value = favoriteSnapShot.value,
            let self = self else { return }

      if let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) {
        do {
          let podcasts = try JSONDecoder(context: self.viewContext).decode([FavoritePodcast].self, from: data)
          podcasts.forEach {
            _ = FavoritePodcast.getOrCreateFavoritePodcast($0)
          }
          self.viewContext.mySave()
        } catch {
          print(error)
        }
        completion()
      }
    }
  }
}

extension FirebaseDatabase {
  
  private func save<T: Codable & NSManagedObject>(type: T.Type, completion: (Any) -> Void) {
    guard let value = try? viewContext.fetch(NSFetchRequest<T>(entityName: T.entityName)) else { return }
    if let podcastData = try? JSONEncoder().encode(value) {
      if let serialization = try? JSONSerialization.jsonObject(with: podcastData, options: .allowFragments) as? [Dictionary<String, Any>] {
        completion(serialization)
      }
    }
  }
  
  private func obtain<T: Codable & NSManagedObject>(type: T.Type, snapshot: DataSnapshot, completion: @escaping ([T]) -> Void) {
    guard let value = snapshot.value else { return }
    T.removeAll()
    if let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) {
      do {
        let result = try JSONDecoder(context: self.viewContext).decode([T].self, from: data)
        completion(result)
      } catch {
        print(error)
      }
    }
  }
}





