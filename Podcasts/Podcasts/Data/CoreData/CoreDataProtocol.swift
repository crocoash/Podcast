//
//  CoreDataProtocol.swift
//  Podcasts
//
//  Created by Anton on 23.02.2023.
//

import CoreData

protocol CoreDataProtocol where Self: NSManagedObject & Hashable {
    
    associatedtype T: NSManagedObject, Identifiable
    
    static var allObjectsFromCoreData: [T] { get }
    
    var searchId: Int? { get }
    
    func saveInCoredataIfNotSaved()
    
    var getFromCoreData: Self? { get }
    var getFromCoreDataIfNoSavedNew: T { get }
   
    
    static func removeAll()
    func removeFromCoreData()
    @discardableResult init(_: Self)
}

extension CoreDataProtocol where Self: NSManagedObject & Identifiable & Hashable  {

    static var allObjectsFromCoreData: [Self] {
        viewContext.fetchObjects(Self.self)
    }

    static func removeAll() {
        allObjectsFromCoreData.forEach {
            $0.removeFromCoreData()
        }
    }

    var getFromCoreData: Self? {
        return Self.allObjectsFromCoreData.first(matching: self)
    }

    func saveInCoredataIfNotSaved() {
        if getFromCoreData == nil {
            Self.init(self)
        }
    }

    var getFromCoreDataIfNoSavedNew: Self {
        return Self.allObjectsFromCoreData.first(matching: self) ?? Self.init(self)
    }

    static func getFromCoreData(searchId: Int) -> Self? {
        allObjectsFromCoreData.filter { $0.searchId == searchId }.first
    }
    
    func removeFromCoreData() {
        print("print1 \(Self.self)")
        for selfKey in self.entity.propertiesByName.keys {
            
            let selfValue = self.value(forKey: selfKey)
            
            if let subItem = selfValue as? (any CoreDataProtocol) {
                print("print 1.2` \(String(describing: subItem.entityName))")
                checkSubItem(item: subItem)
            } else if let subItems = selfValue as? Set<NSManagedObject> {
                subItems.forEach {
                    print("print 1.3 \($0.entityName)")
                        checkSubItem(item: $0)
                }
            }
        }
        
        viewContext.delete(self)
        mySave()
    }
    
    private func checkSubItem(item: NSManagedObject) {
        
        let relationshipsKeys = item.entity.relationshipsByName.keys
        
        
        var isEmptyLink = true
        
        for key in relationshipsKeys {
            
            let value = item.value(forKey: key)
            
            guard let relationship = item.entity.relationshipsByName[key],
                  let destinationEntity = relationship.destinationEntity,
                  let destinationEntityName = destinationEntity.name else { fatalError() }
            
            let deleteRule = relationship.deleteRule
            
//            let destinationEntityManagedObjectClassName = destinationEntity.managedObjectClassName
            
//            print("print destinationEntityName \(destinationEntityName) --- \(Self.entityName)")
//            print("print relationship \(relationship)")
//            print("print destinationEntity \(destinationEntity) ")
           


            if destinationEntityName == Self.entityName {
                
                if value is Self {
                    
                    item.setNilValueForKey(key)
                    
                } else if let set = value as? Set<Self> {
                    
                    let set = set.filter { $0.entityName != self.entityName }
                    item.setValue(set, forKey: key)
                    
                }
            }
            
            if deleteRule == .denyDeleteRule {
                
                if  value is NSManagedObject {
                    isEmptyLink = false
                } else if let set = value as? Set<NSManagedObject> {
                    if !set.isEmpty {
                        isEmptyLink = false
                    }
                }
            }
        }

        if isEmptyLink {
            for key in relationshipsKeys {
                guard let deleteRule = item.entity.relationshipsByName[key]?.deleteRule else { fatalError() }
                let value = item.value(forKey: key)
                
                if deleteRule == .nullifyDeleteRule {
                    if let entity = value as? (any CoreDataProtocol) {
                        checkSubItem(item: entity)
                    }
                }
            }
            if let item = item as? (any CoreDataProtocol) {
                item.removeFromCoreData()
            }
        }
    }
}

/// ---------------------------------------------------------------------------------------------
protocol FirebaseProtocol: CoreDataProtocol {
    
    var firebaseKey: String? { get }
    
    
    func removeFromFireBase(key: String?, entityName: String)
    func addFromFireBase()
    func saveInFireBase()
    static func updateFromFireBase(completion: ((Result<[T]>) -> Void)?)
    var entityName: String { get }
    @discardableResult init(_: Self, viewContext: NSManagedObjectContext)
}

extension FirebaseProtocol {
    
    func removeFromFireBase(key: String?, entityName: String) {
        FirebaseDatabase.shared.remove(entityName: entityName, key: key)
    }
    
    func saveInFireBase() {
        FirebaseDatabase.shared.add(object: self, key: firebaseKey)
    }
    
    func addFromFireBase() {
        if getFromCoreData == nil {
            Self.init(self, viewContext: viewContext)
        }
    }
}
