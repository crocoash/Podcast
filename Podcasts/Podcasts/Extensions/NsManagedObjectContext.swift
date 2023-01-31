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
                print("print mySave\(error.localizedDescription)")
            }
        }
    }
    
    func fetchObjects<T: NSManagedObject>(_ type: T.Type) -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
        var objects: [T] = []
        do {
            objects = try self.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        
        return objects
    }
    
    func myDelete(_ object: NSManagedObject) {
        do {
            try object.validateForDelete()
            self.delete(object)
        } catch let error {
            print("print \(error)")
            print("print can not delete \(object)")
        }
    }
}
