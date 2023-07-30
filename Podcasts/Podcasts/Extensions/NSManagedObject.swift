//
//  NSManagedObject.swift
//  Podcasts
//
//  Created by Anton on 21.08.2022.
//

import CoreData

extension NSManagedObject {
    
    static var entityName: String { String(describing: Self.self)  }
    var entityName: String { String(describing: Self.self)  }
    
    
    func isPropertiesConform<T>(to protocol: T) -> Bool {
        
        for selfKey in self.entity.propertiesByName.keys {
            let value = self.value(forKey: selfKey)
            if value is T {
                return true
            }
        }
        return false
    }
}

extension NSManagedObject {
  var convert: [String: Any]? {
    if let self = self as? Encodable {
        if let data = try? JSONEncoder().encode(self) {
            if let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                return result
            } else {
                fatalError("Cannot conver object")
            }
        }
    }
      return nil
  }
}

extension NSManagedObject {
    
    convenience init(_ entity: NSManagedObject) {
        
        self.init(entity: entity.entity, insertInto: nil)
        
        for initProp in self.entity.propertiesByName {
            let value = entity.value(forKey: initProp.key)
            if let value = value, !(value is NSManagedObject) {
                self.setValue(value, forKey: initProp.key)
            }
        }
    }
    
    func updateObject(by entity: NSManagedObject) {
        for initProp in self.entity.propertiesByName {
            let value = entity.value(forKey: initProp.key)
            if let value = value, !(value is NSManagedObject) {
                self.setValue(value, forKey: initProp.key)
            }
        }
    }
}
