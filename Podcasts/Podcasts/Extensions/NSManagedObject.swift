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
    
    static func fetchObjectsOf<T: NSManagedObject>(_ type: T) -> [T]?  {
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
//        var array = [T]()
//        do {
//           array = try viewContext.fetch(fetchRequest)
//        } catch {
//            print(error)
//        }
        return try? viewContext.fetch(fetchRequest)
      }
}
