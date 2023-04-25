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
        do {
            try validateForDelete()
            removeFromViewContext()
        } catch let error {
            print("print \(error.localizedDescription)")
            print("print can not delete \(self)")
        }
        saveCoreData()
    }
    
    func remove() {
        if let self = self as? (any CoreDataProtocol) {
            if let self = self as? (any FirebaseProtocol)  {
                let key = self.key
                self.self.removeFromCoreDataWithOwnEntityRule()
                self.self.removeFromFireBase(key: key)
            } else {
                self.removeFromCoreDataWithOwnEntityRule()
            }
            saveCoreData()
        } else {
            fatalError()
        }
    }
    
    func removeFromViewContext() {
        Self.viewContext.delete(self)
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




