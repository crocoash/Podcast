//
//  extensionCoreData.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 20.03.2022.
//

import Foundation
import CoreData

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

extension JSONDecoder {
    convenience init(context: NSManagedObjectContext) {
        self.init()
        self.userInfo[.context] = context
    }
}

protocol SearchProtocol {
    static func removeAll(from viewContext: NSManagedObjectContext)
}
