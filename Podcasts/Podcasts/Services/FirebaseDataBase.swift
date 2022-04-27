//
//  FirebaseDataBase.swift
//  Podcasts
//
//  Created by Anton on 23.04.2022.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

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
  
  func getPodcast(completion: @escaping ([Podcast]) -> Void) {
    favoritePodcasts.getData { [weak self] error, snapShot in
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
        
      }
    }
  }
  
  func observe() {
    favoritePodcasts.observe(.value) { [weak self] snapShot in
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
}






