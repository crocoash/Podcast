//
//  OffLineStorage+CoreDataClass.swift
//  Podcasts
//
//  Created by Anton on 21.01.2023.
//
//

import Foundation
import CoreData


public class OffLineStorage: NSManagedObject {

    convenience init() {
        self.init(entity: Self.entity(), insertInto: Self.viewContext)
        Self.viewContext.mySave()
    }
}
