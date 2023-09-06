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
    
    /// abstract . init to nil
    convenience init(_ entity: NSManagedObject, viewContext: NSManagedObjectContext? = nil, withRelationShip: Bool = true) {
        
        self.init(entity: entity.entity, insertInto: viewContext)
        
        for initProp in self.entity.propertiesByName {
            let key = initProp.key
            if let value = entity.value(forKey: key) {
                set(value: value, for: key, withRelationShip: withRelationShip)
            }
        }
    }
    
    @discardableResult
    func updateObject(by entity: NSManagedObject, withRelationShip: Bool = false) -> NSManagedObject {
        for initProp in self.entity.propertiesByName {
            let key = initProp.key
            if let value = entity.value(forKey: key) {
                set(value: value, for: key, withRelationShip: withRelationShip)
            }
        }
        return self
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
    
    
    private func setObject( by object: NSManagedObject, for key: String) {
        
        if let viewContext = self.managedObjectContext {
            
            if object.managedObjectContext != nil {
                self.setValue(object, forKey: key)
            } else {
                let value = self.updateObject(by: object, withRelationShip: false)
                self.setValue(value, forKey: key)
            }
        } else {
            if object.managedObjectContext == nil {
                self.setValue(object, forKey: key)
            } else {
                let abstractValue = NSManagedObject.init(object, withRelationShip: false)
                self.setValue(abstractValue, forKey: key)
            }
        }
    }
    
    private func setObjects(by values: Set<NSManagedObject>, for key: String) {
        guard !values.isEmpty else { return }
        
        /// not abstract
        if let viewContext = self.managedObjectContext {
            
            ///  view context matched
            if values.first?.managedObjectContext == viewContext {
                self.setValue(values, forKey: key)
            ///  by abstract entity
            } else {
                if let oldValues = (value(forKey: key) as? Set<NSManagedObject>).map({$0}) {
                    let updatedValues = oldValues.compactMap { oldValue in
                        
                        if let value: NSManagedObject = values.first(where: {
                            
                            if let oldId = oldValue.value(forKey: "id") as? String, let id = $0.value(forKey: "id") as? String {
                                return oldId == id
                            }
                            return false
                        }) {
                            return oldValue.updateObject(by: value, withRelationShip: false)
                        }
                        return nil
                    }
                    self.setValue(Set(updatedValues) as NSSet, forKey: key)
                }
            }
          /// abstract
        } else {
            ///  view context matched
            if values.first?.managedObjectContext == nil  {
                self.setValue(values, forKey: key)
            } else {
                /// by not abstract 
                let abstractValue = values.map { NSManagedObject($0, withRelationShip: false) }
                self.setValue(Set(abstractValue) as NSSet, forKey: key)
            }
        }
    }
}
