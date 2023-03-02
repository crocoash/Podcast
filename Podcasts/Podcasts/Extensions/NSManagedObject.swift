//
//  NSManagedObject.swift
//  Podcasts
//
//  Created by Anton on 21.08.2022.
//

import CoreData

extension NSManagedObject {
    
    static var entityName: String { String(describing: Self.self)  }
    static var viewContext: NSManagedObjectContext { DataStoreManager.shared.viewContext }
    
    func saveCoreData() {
        Self.viewContext.mySave()
    }
    
    func saveInit() {
        saveCoreData()
        if let self = self as? (any FirebaseProtocol) {
            self.saveInFireBase()
        }
    }
    
    func myValidateDelete() {
        Self.viewContext.myValidateDelete(self)
    }
    
    func remove() {
        if let self = self as? (any CoreDataProtocol), let self = self as? (any FirebaseProtocol)  {
            let key = self.key
            self.self.removeFromCoreData()
            self.self.removeFromFireBase(key: key)
        } else if let self = self as? (any CoreDataProtocol) {
            self.removeFromCoreData()
        } else {
            
        }
    }
}

extension NSManagedObject {
  var convert: [String: Any]? {
    if let self = self as? Encodable {
      if let data = try? JSONEncoder().encode(self) {
        if let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
          return result
        }
      }
    }
    return nil
  }
}




