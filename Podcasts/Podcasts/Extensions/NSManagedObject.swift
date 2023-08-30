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
    
    /// abstruct . init to nil
    convenience init(_ entity: NSManagedObject, withRelationShip: Bool = true) {
        
        self.init(entity: entity.entity, insertInto: nil)
        
        for initProp in self.entity.propertiesByName {
            let key = initProp.key
            if let value = entity.value(forKey: key) {
                set(value: value, for: key, withRelationShip: withRelationShip)
            }
        }
    }
    
    func updateObject(by entity: NSManagedObject) {
        for initProp in self.entity.propertiesByName {
            let key = initProp.key
            if let value = entity.value(forKey: key) {
                set(value: value, for: key, withRelationShip: false)
            }
        }
    }
}

//MARK: - Private Methods
extension NSManagedObject {
    private func set(value: Any, for key: String, withRelationShip: Bool) {
        if let object = value as? NSManagedObject {
            if withRelationShip {
                setObject(by: object, for: key)
            }
        } else if let objects = value as? Set<NSManagedObject> {
            if withRelationShip {
                setObjects(by: objects, for: key)
            }
        } else {
            setValue(value, forKey: key)
        }
    }
    
    private func setObject( by value: NSManagedObject, for key: String) {
        
        if let viewContext = self.managedObjectContext {
            
            if value.managedObjectContext != nil {
                self.setValue(value, forKey: key)
            } else {
                let value = NSManagedObject.init(context: viewContext)
                self.setValue(value, forKey: key)
            }
        } else {
            if value.managedObjectContext == nil {
                self.setValue(value, forKey: key)
            } else {
                let abstructValue = NSManagedObject.init(value, withRelationShip: false)
                self.setValue(abstructValue, forKey: key)
            }
        }
    }
    
    private func setObjects( by values: Set<NSManagedObject>, for key: String) {
        guard !values.isEmpty else { return }
        
        if let viewContext = self.managedObjectContext {
            if values.first?.managedObjectContext != nil {
                self.setValue(values, forKey: key)
            } else {
                let values = values.map { NSManagedObject.init(entity: $0.entity, insertInto: viewContext) }
                self.setValue(values, forKey: key)
            }
        } else {
            if values.first?.managedObjectContext == nil  {
                self.setValue(values, forKey: key)
            } else {
                let abstructValue = values.map { NSManagedObject.init(entity: $0.entity, insertInto: nil) }
                self.setValue(abstructValue, forKey: key)
            }
        }
    }
}
