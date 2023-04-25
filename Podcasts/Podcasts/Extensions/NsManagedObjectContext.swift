//
//  NsManagedObjectContext.swift
//  Podcasts
//
//  Created by Anton on 21.08.2022.
//

import CoreData

extension NSManagedObjectContext {
    
    func mySave() {
        if self.hasChanges {
            do {
                try self.save()
            } catch {
                print(error)
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
