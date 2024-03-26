//
//  FirebaseDataBase.swift
//  Podcasts
//
//  Created by Anton on 23.04.2022.
//

import Foundation
import FirebaseDatabase
import CoreData


/// ---------------------------------------------------------------------------------------------
//MARK: - Type
protocol FirebaseProtocol: CoreDataProtocol {
    
    var firebaseKey: String { get }
    var entityName: String { get }
}

extension FirebaseProtocol {
    
//    typealias ResultType = Result<[Self]>
    
    var firebaseKey: String { return id }
}

//MARK: - Input
//protocol FirebaseDatabaseInput {
//   func update(entity: any FirebaseProtocol)
//   func update<T: FirebaseProtocol>(vc: (any FirebaseDatabaseDelegate), viewContext: NSManagedObjectContext, type: T.Type)
//   func add(entity: any FirebaseProtocol)
//   func remove(entity: any FirebaseProtocol)
//   func observe<T: FirebaseProtocol>(vc: (any FirebaseDatabaseDelegate),viewContext: NSManagedObjectContext, type: T.Type)
//}
 
//MARK: - Delegate
protocol FirebaseDatabaseDelegate: AnyObject {
   
   func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didGetEmptyData type: any FirebaseProtocol.Type)
   func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entity: (any FirebaseProtocol))
   func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didRemove entity: (any FirebaseProtocol))
   func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entities: [any FirebaseProtocol])
   func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didUpdate entity: (any FirebaseProtocol))
}

class FirebaseDatabase: ISingleton {
   
   typealias Arguments = Void
   
   required init(container: IContainer, args: Arguments) {

      let userViewModel: UserViewModel = container.resolve()

      self.userID = userViewModel.userDocument.user.userId
   }
   
   private let userID: String
   
   private var ref = Database.database(url: "https://podcast-app-8fcd2-default-rtdb.europe-west1.firebasedatabase.app").reference()
   lazy private var userStorage = ref.child(userID)
   private let connectedRef: DatabaseReference = Database.database(url: "https://podcast-app-8fcd2-default-rtdb.europe-west1.firebasedatabase.app").reference(withPath: ".info/connected")
   
   func add(entity: any FirebaseProtocol) {
      let serialization = entity.convert
//      let ref = userStorage.child(entity.entityName).child(entity.firebaseKey)
      
//      ref.getData { [weak self] error, snapShot in
//         guard let self = self else { return }
//         if snapShot?.value is NSNull {
            userStorage.child(entity.entityName).child(entity.firebaseKey).setValue(serialization)
//         }
//      }
   }
   
   func update(entity: any FirebaseProtocol) {
      let serialization = entity.convert
      userStorage.child(entity.entityName).child(entity.firebaseKey).setValue(serialization)
   }
   
   func remove(entity: any FirebaseProtocol) {
      userStorage.child(entity.entityName).child(entity.firebaseKey).removeValue()
   }
   
   func update<T: FirebaseProtocol>(vc: (any FirebaseDatabaseDelegate), viewContext: NSManagedObjectContext, type: T.Type) {

      userStorage.child(T.entityName).getData { [weak self] error, snapShot in
         
         guard let self = self else { return }
         
         if let error = error {
            //TODO:
//            print(error)
            return
         }

         guard let value = snapShot?.value, !(value is NSNull) else {
            vc.firebaseDatabase(self, didGetEmptyData: T.self)
            return
         }
         
         if let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) {
            do {
               let res = try JSONDecoder(context: viewContext).decode([String:T].self, from: data)
               let entities = res.compactMap { $0.value }
               vc.firebaseDatabase(self, didAdd: entities)
            } catch {
               //TODO:
//               completion(.failure(.firebaseDatabase(.error(error))))
            }
         }
      }
   }
   
   func observe<T: FirebaseProtocol>(vc: (any FirebaseDatabaseDelegate), viewContext: NSManagedObjectContext, type: T.Type) {
      
      Database.database().isPersistenceEnabled = true
      
      connectedRef.observe(.value, with: { [weak self] snapshot in
         guard let self = self else { return }
         if snapshot.value as? Bool ?? false {
            
            ///childAdded
           let childPath = userStorage.child(T.entityName)
            
            childPath.observe(.childAdded) { [weak self] snapshot in
               guard let self = self else { return }
               
               obtain(snapshot: snapshot, viewContext: viewContext) { [weak self] (result: Result<T, MyError.FirebaseDatabase>) in
                  guard let self = self else { return }
                  
                  switch result {
                  case .success(result: let entity):
                     vc.firebaseDatabase(self, didAdd: entity)
                  case .failure(error: let error):
                     print()

//                     print("erorr \(error)")
                  }
               }
            }
            
            ///childRemoved
            childPath.observe(.childRemoved) { [weak self] snapshot in
               self?.obtain(snapshot: snapshot, viewContext: viewContext) { [weak self] (result: Result<T, MyError.FirebaseDatabase>) in
                  guard let self = self else { return }

                  switch result {
                  case .success(result: let entity):
                     vc.firebaseDatabase(self, didRemove: entity)
                  case .failure(error: let error):
                     print()
//                     print("erorr \(error)")
                  }
               }
            }
            
            ///childChanged
            childPath.observe(.childChanged) { [weak self] snapshot in
               
               self?.obtain(snapshot: snapshot, viewContext: viewContext) { [weak self] (result: Result<T, MyError.FirebaseDatabase>) in
                  guard let self = self else { return }
                  
                  switch result {
                  case .success(result: let entity):
                     vc.firebaseDatabase(self, didUpdate: entity)
                  case .failure(error: let error) :
                     print()

//                     print("erorr \(error)")
                  }
               }
            }
         }
      })
   }
}

// MARK: - Private Methods
extension FirebaseDatabase {
   
   private func obtain<T: FirebaseProtocol>(snapshot: DataSnapshot, viewContext: NSManagedObjectContext, completion: @escaping (Result<T, MyError.FirebaseDatabase>) -> Void) {
      guard let value = snapshot.value else { return }
      if let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) {
         do {
            let entity = try JSONDecoder(context: viewContext).decode(T.self, from: data)
            completion(.success(result: entity))
         } catch let error as NSError {
            completion(.failure(.error(error)))
         }
      }
   }
}

//
//extension Notification.Name {
//   static var noInternet: Notification.Name { Notification.Name("NotificationIdentifier") }
//}


