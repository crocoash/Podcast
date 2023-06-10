//
//  NsManagedObjectContext.swift
//  Podcasts
//
//  Created by Anton on 21.08.2022.
//

import CoreData

extension NSManagedObjectContext {
    
    func mySave() {
        self.performAndWait {
            
            if self.hasChanges {
                
                let inseretObjects = self.insertedObjects.compactMap { $0 as? (any FirebaseProtocol) }
                let deletedObjects: [(key: String?, entityName: String, object: (any FirebaseProtocol))] = self.deletedObjects.compactMap { $0 as? (any FirebaseProtocol) }.map { (key: $0.firebaseKey, entityName: $0.entityName, object: $0)}
                let updatedObjects = self.updatedObjects.compactMap { $0 as? (any FirebaseProtocol) }
                
                do {
                    try self.save()
                } catch {  
//                    self.rollback()
                }
                
                inseretObjects.forEach { $0.saveInFireBase() }
                deletedObjects.forEach { $0.object.removeFromFireBase(key: $0.key, entityName: $0.entityName) }
            }
        }
    }
    
    func fetchObjects<T: NSManagedObject>(_ type: T.Type) -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
        do {
             return try self.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)         
        }
        return []
    }
}
