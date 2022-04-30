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
  
  lazy private var favoritePodcastsPath = ref.child(userID).child("FavoritePodcasts")
  lazy private var likedPodcastsPath = ref.child(userID).child("LikedPodcasts")
  
  func savePodcast() {
    guard let podcasts = try? self.viewContext.fetch(Podcast.fetchRequest()) else { return }
    if let podcastData = try? JSONEncoder().encode(podcasts) {
      if let serialization = try? JSONSerialization.jsonObject(with: podcastData, options: .allowFragments) as? [Dictionary<String, Any>] {
        favoritePodcastsPath.setValue(serialization)
      }
    }
  }
  
  func observePodcast() {
    favoritePodcastsPath.observe(.value) { [weak self] snapShot in
      guard let value = snapShot.value,
            let self = self else { return }
      
      DataStoreManager.shared.removeAll(fetchRequest: Podcast.fetchRequest())
      
      if let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) {
        do {
          let podcasts = try JSONDecoder(context: self.viewContext).decode([Podcast].self, from: data)
          podcasts.forEach { podcast in
            _ = Podcast(podcast: podcast)
          }
          self.viewContext.mySave()
        } catch let error {
          print(error)
        }
        
      }
      
      self.delegate?.firebaseDatabaseDidGetData(self)
    }
  }
  
  func getPodcast(completion: @escaping ([Podcast]) -> Void) {
    favoritePodcastsPath.getData { [weak self] error, snapShot in
      guard error == nil,
            let value = snapShot.value,
            let self = self else { return }
      
      if let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) {
        do {
          let podcasts = try JSONDecoder(context: self.viewContext).decode([Podcast].self, from: data)
          podcasts.forEach { podcast in
            _ = Podcast(podcast: podcast)
          }
          completion(podcasts)
          self.viewContext.mySave()
        } catch let error {
          print(error)
        }
        completion()
      }
    }
  }
  
  /// ------
  func saveLikedMoment() {
    guard let podcasts = try? viewContext.fetch(LikedMoment.fetchRequest()) else { return }
    if let podcastData = try? JSONEncoder().encode(podcasts) {
      if let serialization = try? JSONSerialization.jsonObject(with: podcastData, options: .allowFragments) as? [Dictionary<String, Any>] {
        likedPodcastsPath.setValue(serialization)
      }
    }
  }
  
  func observeLikedMoment() {
    likedPodcastsPath.observe(.value) { [weak self] snapShot in
      guard let value = snapShot.value,
            let self = self else { return }
      
      DataStoreManager.shared.removeAll(fetchRequest: LikedMoment.fetchRequest())
      
      if let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) {
        do {
          let likeMoments = try JSONDecoder(context: self.viewContext).decode([LikedMoment].self, from: data)
          
          likeMoments.forEach { likeMoment in
            if let podcast = try? self.viewContext.fetch(Podcast.fetchRequest()).firstPodcast(matching: likeMoment.podcastID) {
              let newLikedMoment = LikedMoment(context: self.viewContext)
              newLikedMoment.podcast = podcast
              newLikedMoment.moment = likeMoment.moment
              newLikedMoment.podcastID = likeMoment.podcastID
            }
          }
          self.viewContext.mySave()
        } catch let error {
          print(error)
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





