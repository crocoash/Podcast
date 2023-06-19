//
//  CoreDataProtocol.swift
//  Podcasts
//
//  Created by Anton on 23.02.2023.
//

import CoreData

protocol CoreDataProtocol where Self: NSManagedObject & Hashable & Identifiable {
    
//    associatedtype T: NSManagedObject, Identifiable
    
//    static var allObjectsFromCoreData: [T] { get }
    
    var identifier: String { get }
    func saveInCoredataIfNotSaved()
    
//    var getFromCoreData: Self? { get }
//    var getFromCoreDataIfNoSavedNew: T { get }
   
    
//    static func removeAll()
//    func removeFromCoreData()
    @discardableResult init(_: Self)
}

extension CoreDataProtocol where Self: NSManagedObject & Identifiable & Hashable  {

    static func removeAll() {
        allObjectsFromCoreData.forEach {
            $0.removeFromCoreData()
        }
    }

    static var allObjectsFromCoreData: Set<Self> {
        viewContext.fetchObjects(Self.self)
    }
    
    var getFromCoreData: Self? {
        return fetchObject()
    }
    
    /// LikedMoments dont have save init
    func saveInCoredataIfNotSaved() {
        if getFromCoreData == nil {
            Self.init(self)
        }
    }
    
    var getFromCoreDataIfNoSavedNew: Self {
        return getFromCoreData ?? Self.init(self)
    }
    
//    static func getFromCoreData(searchId: Int) -> Self? {
////        allObjectsFromCoreData.filter { $0.searchId == searchId }.first
//    }
    
    var defaultPredicate: NSPredicate {
        return NSPredicate(format: "identifier == %@", "\(identifier)")
    }
    
    func fetchObject(predicates: [NSPredicate]? = nil) -> Self? {
        
        let fetchRequest: NSFetchRequest<Self> = Self.fetchRequest() as! NSFetchRequest<Self>
       
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates ?? [defaultPredicate])
        
        fetchRequest.fetchLimit = 1
        let result = try? Self.viewContext.fetch(fetchRequest)
        return result?.first
    }
    
    static func fetchObjects(predicates: [NSPredicate]) -> [Self]? {
        
        let fetchRequest: NSFetchRequest<Self> = Self.fetchRequest() as! NSFetchRequest<Self>
       
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        return try? viewContext.fetch(fetchRequest)
    }
    
    static func fetchObject(predicates: [NSPredicate]) -> Self? {
        
        let fetchRequest: NSFetchRequest<Self> = Self.fetchRequest() as! NSFetchRequest<Self>
       
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates )
        
        fetchRequest.fetchLimit = 1
        let result = try? viewContext.fetch(fetchRequest)
        return result?.first
    }
    
    func fetchResultController(
        sortDescription: [NSSortDescriptor]?,
        predicates: [NSPredicate]? = nil,
        sectionNameKeyPath: String? = nil,
        fetchLimit: Int? = nil
    ) -> NSFetchedResultsController<Self> {
        
        let fetchRequest: NSFetchRequest<Self> = Self.fetchRequest() as! NSFetchRequest<Self>
        
        if let predicates = predicates {
            for predicate in predicates {
                fetchRequest.predicate = predicate
            }
        }
        
        fetchRequest.fetchLimit = fetchLimit ?? Int.max
        fetchRequest.sortDescriptors = sortDescription
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil
        )
        
        do {
            try fetchResultController.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(error), \(nserror.userInfo)")
        }
        return fetchResultController
    }

    
    func updateEntity() {
        
    }
    
    func removeFromCoreData() {

        guard let self = getFromCoreData else { return  }
        
        for key in self.entity.relationshipsByName.keys {
            
            let value = self.value(forKey: key)
            
            if let value = value as? NSManagedObject {
                checkSubItem(item: value, with: self)
            } else if let values = value as? Set<NSManagedObject> {
                values.forEach {
                    checkSubItem(item: $0, with: self)
                }
            }
        }
        
        viewContext.delete(self)
        mySave()
    }
    
    private func checkSubItem<T: NSManagedObject>(item: NSManagedObject, with checkItem: T) {

        let keys = item.entity.relationshipsByName.keys
        
        var isEmptyLink = true
        
        for key in keys {
                        
            guard let relationship = item.entity.relationshipsByName[key],
                  let destinationEntity = relationship.destinationEntity,
                  let destinationEntityName = destinationEntity.name else { fatalError() }
            
            let deleteRule = relationship.deleteRule
                  
            if destinationEntityName == checkItem.entityName {
                
                if item.value(forKey: key) is T {
                    
                    item.setNilValueForKey(key)
                    mySave()
                } else if let set = item.value(forKey: key) as? Set<T> {
                    let set = set.filter { $0.objectID != checkItem.objectID }
                    item.setValue(set, forKey: key)
                    mySave()
                }
            }
            
            if deleteRule == .denyDeleteRule {
                
                if let _ = item.value(forKey: key) as? NSManagedObject {
                    isEmptyLink = false
                } else if let set = item.value(forKey: key) as? Set<NSManagedObject> {
                    if !set.isEmpty {
                        isEmptyLink = false
                    }
                }
            }
        }

        if isEmptyLink {
            for key in keys {
                guard let deleteRule = item.entity.relationshipsByName[key]?.deleteRule else { fatalError() }
                
                let value = item.value(forKey: key)
                
                if deleteRule == .nullifyDeleteRule {
                    if let entity = value as? NSManagedObject {
                        checkSubItem(item: entity, with: entity)
                    } else if let set = value as? Set<NSManagedObject> {
                        set.forEach {
                            checkSubItem(item: $0, with: item)
                        }
                    }
                    item.setNilValueForKey(key)
                    mySave()
                }
            }
            
            viewContext.delete(item)
            mySave()
        }
    }
}




















/// ---------------------------------------------------------------------------------------------
protocol FirebaseProtocol: CoreDataProtocol & Decodable  {
    
    var firebaseKey: String { get }
    
    func removeFromFireBase(key: String?, entityName: String)
    func addFromFireBase()
    func saveInFireBase()
    
    var entityName: String { get }
    @discardableResult init(_: Self, viewContext: NSManagedObjectContext)
}

extension FirebaseProtocol where Self: Decodable {
    
    typealias ResultType = Result<Set<Self>>
    
    var firebaseKey: String { identifier }
    
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

extension Set where Element: FirebaseProtocol {
    
    func updateCoreData() {
        
        let allObjectsFromCoreData = Element.allObjectsFromCoreData
        
        let newObjects = self.filter { $0.fetchObject() == nil }
        
        ///create new
        newObjects.forEach {
            Element.init($0)
        }
        
        let removedObjects = allObjectsFromCoreData.filter {  $0.fetchObject() == nil }
        
        /// remove
        removedObjects.forEach {
            $0.removeFromCoreData()
        }
    }
}
