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
   private let connectedRef: DatabaseReference = Database.database(url: "https://podcast-app-8fcd2-default-rtdb.europe-west1.firebasedatabase.app").reference(withPath: ".info/connected")
   
   
   func add<T: NSManagedObject>(object: T, key: String?) {
      guard let key = key else { return }
      let serialization = object.convert
      userStorage.child(T.entityName).child(key).setValue(serialization)
   }
   
   func remove(entityName: String, key: String?) {
      guard let key = key, key != "", entityName != "" else { return }
      userStorage.child(entityName).child(key).removeValue()
   }
   
   func update<T: FirebaseProtocol>(completion: @escaping (Result<Set<T>>) -> Void) {
      userStorage.child(T.entityName).getData { [weak self] error, snapShot in
         
         guard let self = self else { return }
         
         if let error = error {
            completion(.failure(.firebaseDatabase(.error(error as Error))))
            return
         }
         
         if snapShot?.value is NSNull {
            completion(.failure(.firebaseDatabase(.NSNull)))
            return
         }

         guard let value = snapShot?.value  else {
            completion(.failure(.firebaseDatabase(.snapShotIsNil)))
            return
         }
         
         if snapShot?.value is NSNull {
            T.removeAll()
            return
         }
         
         if let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) {
            do {
               let res = try JSONDecoder(context: self.viewContext).decode([String:T].self, from: data)
               let set = Set(res.compactMap { $0.value })
               set.updateCoreData()
               completion(.success(result: set))
            } catch {
               completion(.failure(.firebaseDatabase(.error(error))))
            }
         }
      }
   }
   
   func observe<T: FirebaseProtocol>(add: @escaping (Result<T>) -> Void, remove: @escaping (Result<T>) -> Void) {
      
      Database.database().isPersistenceEnabled = true
      
      connectedRef.observe(.value, with: { [weak self] snapshot in
         
         if snapshot.value as? Bool ?? false {
            
            ///childAdded
            guard let childPath = self?.userStorage.child(T.entityName) else { fatalError() }
            
            childPath.observe(.childAdded) { [weak self] snapshot in
               self?.obtain(snapshot: snapshot) { (result: Result<T>) in
                  switch result {
                  case .success(result: let object):
                     object.addFromFireBase()
                     add(.success(result: object))
                  case .failure(error: let error):
                     add(.failure(error))
                  }
               }
            }
            
            ///childRemoved
            childPath.observe(.childRemoved) { [weak self] snapshot in
               self?.obtain(snapshot: snapshot) { (result: Result<T>) in
                  switch result {
                  case .success(result: let object):
                     object.removeFromCoreData()
                     remove(.success(result: object))
                  case .failure(error: let error) :
                     remove(.failure(error))
                  }
               }
            }
            
            ///childChanged
            childPath.observe(.childChanged) { [weak self] snapshot in
               self?.obtain(snapshot: snapshot) { (result: Result<T>) in
                  switch result {
                  case .success(result: let object):
                     object.updateEntity()
                  case .failure(error: let error) :
                     add(.failure(error))
                  }
               }
            }
         }
      })
   }
}

protocol FireBaseProtocol: Decodable { }

// MARK: - Private Methods
extension FirebaseDatabase {
   
   private func obtain<T: Decodable>(snapshot: DataSnapshot, completion: @escaping (Result<T>) -> Void) {
      guard let value = snapshot.value else { return }
      if let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) {
         do {
            let result = try JSONDecoder(context: self.viewContext).decode(T.self, from: data)
            completion(.success(result: result))
         } catch let error as NSError {
            completion(.failure(.firebaseDatabase(.error(error))))
         }
      }
   }
}

extension Notification.Name {
   static var noInternet: Notification.Name { Notification.Name("NotificationIdentifier") }
}
