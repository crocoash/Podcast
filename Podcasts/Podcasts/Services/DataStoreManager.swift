//
//  CoreDataService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 19.03.2022.
//

import CoreData


protocol DataStoreManagerDelegate: AnyObject {
    func dataStoreManager(_ dataStoreManagerInput: DataStoreManagerInput, didRemoveEntity entities: [NSManagedObject])
    func dataStoreManager(_ dataStoreManagerInput: DataStoreManagerInput, didUpdateEntity entities: [NSManagedObject])
    func dataStoreManager(_ dataStoreManagerInput: DataStoreManagerInput, didAdd entities: [NSManagedObject])
}

protocol DataStoreManagerInput {
    var viewContext: NSManagedObjectContext { get }
    
    func getFromCoreData<T: CoreDataProtocol>(entity: T) -> T?
    
    @discardableResult func getFromCoreDataIfNoSavedNew<T: CoreDataProtocol>(entity: T) -> T
    
    func removeFromCoreData<T: CoreDataProtocol>(entity: T)
    func allObjectsFromCoreData<T: NSManagedObject>(type: T.Type) -> Set<T>
    func fetchObject<T: CoreDataProtocol>(entity: T, predicates: [NSPredicate]?) -> T?
    func fetchObject<T: CoreDataProtocol>(entity: T.Type, predicates: [NSPredicate]?) -> T?
    
    func updateCoreData<T: CoreDataProtocol>(entity: T)
    func updateCoreData<T: CoreDataProtocol>(set: [T])
    func addFromFireBase<T: CoreDataProtocol>(entity: T)
    func saveInCoredataIfNotSaved<T: CoreDataProtocol>(entity: T)
    func removeAll<T: CoreDataProtocol>(type: T.Type)
    func mySave()
    func conFigureFRC<T: NSManagedObject>(for entity: T.Type, with sortDescription: [NSSortDescriptor]) -> NSFetchedResultsController<T>
    
    func fetchResultController<T: NSManagedObject>(
        sortDescription: [NSSortDescriptor]?,
        predicates: [NSPredicate]?,
        sectionNameKeyPath: String?,
        fetchLimit: Int?
    ) -> NSFetchedResultsController<T>
}

protocol CoreDataProtocol where Self: NSManagedObject & Hashable & Identifiable & Decodable {
        
    var identifier: String { get }
   
    @discardableResult
    init(_ entity: Self, viewContext: NSManagedObjectContext?, dataStoreManagerInput: DataStoreManagerInput?)
}


extension CoreDataProtocol where Self: NSManagedObject {
    
    var defaultPredicate: NSPredicate {
        return NSPredicate(format: "identifier == %@", "\(identifier)")
    }
}

final class DataStoreManager {
    
    lazy var viewContext = persistentContainer.viewContext
    lazy var backgroundContext = persistentContainer.newBackgroundContext()
    
    weak var delegate: DataStoreManagerDelegate?
    
    private(set) var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreData")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
}

extension DataStoreManager: DataStoreManagerInput {
    
    typealias Object = NSManagedObject

    func addFromFireBase<T: CoreDataProtocol>(entity: T) {
        getFromCoreDataIfNoSavedNew(entity: entity)
    }
    
    func mySave() {
        
        viewContext.performAndWait {
            
            if viewContext.hasChanges {
                
                let deletedObjects = initAbstractObjects(for: viewContext.deletedObjects)
                let insertedObjects = Array(viewContext.insertedObjects)
                let updatedObjects = Array(viewContext.updatedObjects)
                
                do {
                    try viewContext.save()
                } catch {
                    print("\(error.localizedDescription)")
                }
                
                if insertedObjects.count != 0 {
                    delegate?.dataStoreManager(self, didAdd: insertedObjects)
                }
                
                if updatedObjects.count != 0 {
                    delegate?.dataStoreManager(self, didUpdateEntity: updatedObjects)
                }
                
                if deletedObjects.count != 0 {
                    delegate?.dataStoreManager(self, didRemoveEntity: deletedObjects)
                }
            }
        }
    }
    
    func conFigureFRC<T: NSManagedObject>(for entity: T.Type, with sortDescription: [NSSortDescriptor]) -> NSFetchedResultsController<T> {
        return fetchResultController(sortDescription: sortDescription, predicates: nil, sectionNameKeyPath: nil, fetchLimit: nil)
    }
    
    func fetchResultController<T: NSManagedObject>(
        sortDescription: [NSSortDescriptor]?,
        predicates: [NSPredicate]? = nil,
        sectionNameKeyPath: String? = nil,
        fetchLimit: Int? = nil
    ) -> NSFetchedResultsController<T> {
        
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        
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
    
    func allObjectsFromCoreData<T: NSManagedObject>(type: T.Type) -> Set<T> {
        viewContext.fetchObjects(T.self)
    }
    
    func removeAll<T: CoreDataProtocol>(type: T.Type) {
        let objects = allObjectsFromCoreData(type: type)
        objects.forEach {
            removeFromCoreData(entity: $0)
        }
    }
    
    func fetchObject<T: CoreDataProtocol>(entity: T.Type, predicates: [NSPredicate]? = nil) -> T? {
        
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
       
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates ?? [] )
        
        fetchRequest.fetchLimit = 1
        let result = try? viewContext.fetch(fetchRequest)
        return result?.first
    }
    
    func fetchObject<T: CoreDataProtocol>(entity: T, predicates: [NSPredicate]? = nil) -> T? {
        
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
       
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates ?? [entity.defaultPredicate])
        
        fetchRequest.fetchLimit = 1
        let result = try? viewContext.fetch(fetchRequest)
        return result?.first
    }
    
    func getFromCoreData<T: CoreDataProtocol>(entity: T) -> T? {
        return fetchObject(entity: entity)
    }
    
    func saveInCoredataIfNotSaved<T: CoreDataProtocol>(entity: T) {
        if getFromCoreData(entity: entity) == nil {
            T.init(entity, viewContext: viewContext, dataStoreManagerInput: self)
            mySave()
        }
    }
    
    @discardableResult
    func getFromCoreDataIfNoSavedNew<T: CoreDataProtocol>(entity: T) -> T {
        return getFromCoreData(entity: entity) ?? T.init(entity, viewContext: viewContext, dataStoreManagerInput: self)
    }
    
    func fetchObjects<T: CoreDataProtocol>(predicates: [NSPredicate]) -> [T]? {
        
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
       
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        return try? viewContext.fetch(fetchRequest)
    }
    
    func fetchObject<T: CoreDataProtocol>(predicates: [NSPredicate]) -> T? {
        
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
       
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates )
        
        fetchRequest.fetchLimit = 1
        let result = try? viewContext.fetch(fetchRequest)
        return result?.first
    }
    
    func updateCoreData<T: CoreDataProtocol>(set: [T]) {
        
        let allObjectsFromCoreData = allObjectsFromCoreData(type: T.self)
        
        let newObjects = set.filter { fetchObject(entity: $0) == nil }
        
        ///create new
        newObjects.forEach {
            let _ = T.init($0, viewContext: viewContext, dataStoreManagerInput: self)
        }
        
        let removedObjects = allObjectsFromCoreData.filter { object in set.filter { $0 != object }.first == nil }
        
        /// remove
        removedObjects.forEach {
            removeFromCoreData(entity: $0)
        }
    }
    
    func updateCoreData<T: CoreDataProtocol>(entity: T) {
        let object = getFromCoreData(entity: entity)
        object?.updateObject(by: entity)
    }
    
    func removeFromCoreData<T: CoreDataProtocol>(entity: T) {

        guard let object = getFromCoreData(entity: entity) else { return  }
        
        for key in object.entity.relationshipsByName.keys {
            let value = object.value(forKey: key)
            
            if let value = value as? NSManagedObject {
                checkSubItem(item: value, with: object)
            } else if let values = value as? Set<NSManagedObject> {
                values.forEach {
                    checkSubItem(item: $0, with: object)
                }
            }
        }
        
        viewContext.delete(object)
        mySave()
    }
}

//MARK: - Private Methods
extension DataStoreManager {
    
    private func initAbstractObjects(for objects: Set<NSManagedObject>) -> [NSManagedObject] {
        return objects.map { entity in
            let object = NSManagedObject.init(entity)
            return object
        }
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
                    if let val = value as? NSManagedObject {
                        checkSubItem(item: val, with: item)
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
