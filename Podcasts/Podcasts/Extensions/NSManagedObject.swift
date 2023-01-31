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
    
    static func saveContext() {
        viewContext.mySave()
    }
    
    static func removeAll() {
        if let data = try? viewContext.fetch( NSFetchRequest<Self>(entityName: Self.entityName) ), !data.isEmpty {
            data.forEach {
                viewContext.delete($0)
            }
        }
        Self.saveContext()
    }
    
//    var fetchObjectsreturn: [Self] {
//        let fetchRequest = NSFetchRequest<Self>(entityName: Self.entityName)
//        var objects: [Self] = []
//        do {
//            objects = try Self.viewContext.fetch(fetchRequest)
//        } catch {
//            print(error.localizedDescription)
//        }
//
//        return objects
//    }
}

extension NSManagedObject {
  var convert: [String: Any]? {
    if let new = self as? Encodable {
      if let data = try? JSONEncoder().encode(new) {
        if let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
          return result
        }
      }
    }
    return nil
  }
}

