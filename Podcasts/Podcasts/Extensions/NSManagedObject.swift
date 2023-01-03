//
//  NSManagedObject.swift
//  Podcasts
//
//  Created by Anton on 21.08.2022.
//

import CoreData

extension NSManagedObject {
    
    static var entityName: String { return String(describing: Self.self)  }
    static var viewContext: NSManagedObjectContext { return DataStoreManager.shared.viewContext }
    
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
    
    static func fetchObjectsOf<T>(_ type: T.Type) -> [T] where T: NSManagedObject {
      let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
      var objects: [T] = []
      do {
          objects = try viewContext.fetch(fetchRequest)
      } catch {
        print(error.localizedDescription)
      }
      
      return objects
    }
}
