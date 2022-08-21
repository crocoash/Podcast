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
                fatalError(error.localizedDescription)
            }
        }
    }
}
