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

class FirebaseDatabase {
   
   static var shared = FirebaseDatabase()
   private init() {}
   
   private let userID = Auth.auth().currentUser!.uid
   private var viewContext: NSManagedObjectContext { DataStoreManager.shared.viewContext }
   
   private var ref = Database.database(url: "https://podcast-app-8fcd2-default-rtdb.europe-west1.firebasedatabase.app").reference()
   lazy private var userStorage = ref.child(userID)
   private let connectedRef = Database.database(url: "https://podcast-app-8fcd2-default-rtdb.europe-west1.firebasedatabase.app").reference(withPath: ".info/connected")
   
   func add<T: NSManagedObject>(object: T, key: String) {
      let serialization = object.convert
      userStorage.child(T.entityName).child(key).setValue(serialization)
   }
   
   func remove<T: NSManagedObject>(object: T, key: String) {
      userStorage.child(T.entityName).child(key).removeValue()
   }
   
   func update<T: Decodable & NSManagedObject>( completion: @escaping (Result<[T]>) -> Void) {
      userStorage.child(T.entityName).getData { [weak self] error, snapShot in
         
         guard error == nil, let value = snapShot.value, !(snapShot.value is NSNull), let self = self else {
            if snapShot.value is NSNull {
               completion(.failure(error: MyError.noData))
               return
            }
            completion(.failure(error: MyError.error(error?.localizedDescription ?? "Error")))
            return
         }
         
         if let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) {
            do {
               let res = try JSONDecoder(context: self.viewContext).decode([String:T].self, from: data)
               let array = res.compactMap { $0.value }
               completion(.success(result: array))
            } catch {
               completion(.failure(error: MyError.error(error.localizedDescription)))
            }
         }
      }
   }
   
   func observe<T: NSManagedObject & Decodable>(add: @escaping (T) -> Void, remove: @escaping (T) -> Void) {
      
      Database.database().isPersistenceEnabled = true
      
      connectedRef.observe(.value) { [weak self] snapshot in
         
         if snapshot.value as? Bool ?? false {
            
            guard let self = self else { return }
            
            self.userStorage.child(T.entityName).observe(.childAdded) { [weak self] snapShot in
               self?.obtain(snapshot: snapShot) { (object: T) in
                  add(object)
               }
            }
            
            self.userStorage.child(T.entityName).observe(.childRemoved) { [weak self] snapShot in
               self?.obtain(snapshot: snapShot) { (object: T) in
                  remove(object)
               }
            }
         }
      }
   }
}

protocol FireBaseProtocol: Decodable { }

// MARK: - Private Methods
extension FirebaseDatabase {
   
   private func obtain<T: Decodable>(snapshot: DataSnapshot, completion: @escaping (T) -> Void) {
      guard let value = snapshot.value else { return }
      if let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) {
         do {
            let result = try JSONDecoder(context: self.viewContext).decode(T.self, from: data)
            completion(result)
         } catch {
            print("print \(error)")
         }
      }
   }
}

extension Notification.Name {
   static var noInternet: Notification.Name { Notification.Name("NotificationIdentifier") }
}
