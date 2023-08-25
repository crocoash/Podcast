//
//  NsManagedObjectContext.swift
//  Podcasts
//
//  Created by Anton on 21.08.2022.
//

import CoreData

extension NSManagedObjectContext {
    
    func fetchObjects<T: NSManagedObject>(_ type: T.Type) -> Set<T> {
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
        do {
             return try Set(self.fetch(fetchRequest))
        } catch {
            print(error.localizedDescription)         
        }
        return []
    }
    
    func fetchObjects(_ entityName: String) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        do {
             return try self.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    
    func fetchObjectsArray<T: NSManagedObject>(_ type: T.Type, sortDescriptors: [NSSortDescriptor]? = nil, predicates: [NSPredicate]? = nil) -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates ?? [])
        do {
             return try self.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
}
