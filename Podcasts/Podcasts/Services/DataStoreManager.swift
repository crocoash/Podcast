//
//  CoreDataService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 19.03.2022.
//

import CoreData


//MARK: - Input
protocol DataStoreManagerInput {
    
    var viewContext: NSManagedObjectContext { get }
    var backgroundViewContext: NSManagedObjectContext { get }
    
    func getFromCoreDataIfNoSavedNew<T: CoreDataProtocol>(entity: T) -> T
    func removeFromCoreData<T: CoreDataProtocol>(entity: T)
    func allObjectsFromCoreData<T: NSManagedObject>(type: T.Type) -> Set<T>
    func fetchObject<T: CoreDataProtocol>(entity: T, predicates: [NSPredicate]?) -> T?
    func fetchObject<T: CoreDataProtocol>(entity: T.Type, predicates: [NSPredicate]?) -> T?
    
    func updateCoreData<T: CoreDataProtocol>(entity: T)
    func updateCoreData(entities: [(any CoreDataProtocol)])
    func save()
    
    /// inits
    func initAbstractObjects<T: NSManagedObject>(for objects: Set<T>) -> [T]
    func initAbstractObject<T: NSManagedObject>(for objects: T) -> T
    
    ///frc
    func conFigureFRC<T: CoreDataProtocol>(for entity: T.Type) -> NSFetchedResultsController<T>
    func conFigureFRC<T: CoreDataProtocol>(for entity: T.Type, with sortDescription: [NSSortDescriptor]) -> NSFetchedResultsController<T>
    func conFigureFRC<T: CoreDataProtocol>(for entity: T.Type, with sortDescription: [NSSortDescriptor], predicates: [NSPredicate]) -> NSFetchedResultsController<T>
    
    func fetchResultController<T: CoreDataProtocol>(
        sortDescription: [NSSortDescriptor]?,
        predicates: [NSPredicate]?,
        sectionNameKeyPath: String?,
        fetchLimit: Int?
    ) -> NSFetchedResultsController<T>
}

//MARK: - Type
protocol CoreDataProtocol where Self: NSManagedObject & Hashable & Identifiable & Codable {
    var id: String { get }
    static var defaultSortDescription: [NSSortDescriptor] { get }
    
    init(_ entity: Self, viewContext: NSManagedObjectContext, dataStoreManagerInput: DataStoreManagerInput)
}

extension CoreDataProtocol {
    
    var defaultPredicate: NSPredicate {
        return NSPredicate(format: "id == %@", "\(id)")
    }
    
    init(_ entity: Self, viewContext: NSManagedObjectContext, dataStoreManagerInput: DataStoreManagerInput) {
        
        self.init(entity: entity.entity, insertInto: viewContext)
        
        for initProp in self.entity.propertiesByName {
            let value = entity.value(forKey: initProp.key)
            if let value = value {
                if let object = value as? (any CoreDataProtocol) {
                    let object = dataStoreManagerInput.getFromCoreDataIfNoSavedNew(entity: object)
                    setValue(object, for: initProp.key)
                } else if let objects = value as? Set<NSManagedObject> {
                    let entities: [NSManagedObject] = objects.compactMap {
                        if let object = $0 as? (any CoreDataProtocol) {
                            return dataStoreManagerInput.getFromCoreDataIfNoSavedNew(entity: object)
                        }
                        return nil
                    }
                    setValue(Set(entities) as NSSet, for: initProp.key)
                } else {
                    self.setValue(value, forKey: initProp.key)
                }
                
                func setValue(_ value: Any, for key: String) {
                    self.setValue(value, forKey: key)
                }
            }
        }
    }
}

final class DataStoreManager {
    
    lazy var viewContext = persistentContainer.viewContext
    lazy var backgroundContext = persistentContainer.newBackgroundContext()
    
    private(set) var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreData")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var backgroundViewContext = persistentContainer.newBackgroundContext()
    
    func test() {
        backgroundViewContext.undoManager = UndoManager()
    }
}

extension DataStoreManager: DataStoreManagerInput {
 
    func save() {
        viewContext.performAndWait {
            if viewContext.hasChanges {
                do {
                    try viewContext.save()
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
        }
    }
    
    func conFigureFRC<T: CoreDataProtocol>(for entity: T.Type) -> NSFetchedResultsController<T> {
        return fetchResultController(sortDescription: nil, predicates: nil, sectionNameKeyPath: nil, fetchLimit: nil)
    }
    
    func conFigureFRC<T: CoreDataProtocol>(for entity: T.Type, with sortDescription: [NSSortDescriptor]) -> NSFetchedResultsController<T> {
        return fetchResultController(sortDescription: sortDescription)
    }
    
    func conFigureFRC<T: CoreDataProtocol>(for entity: T.Type, with sortDescription: [NSSortDescriptor], predicates: [NSPredicate]) -> NSFetchedResultsController<T> {
        fetchResultController(sortDescription: sortDescription, predicates: predicates)
    }
    
    func fetchResultController<T: CoreDataProtocol>(
        sortDescription: [NSSortDescriptor]?,
        predicates: [NSPredicate]? = nil,
        sectionNameKeyPath: String? = nil,
        fetchLimit: Int? = nil
    ) -> NSFetchedResultsController<T> {
        
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        
        if let predicates = predicates {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        fetchRequest.fetchLimit = fetchLimit ?? Int.max
        fetchRequest.sortDescriptors = sortDescription ?? T.defaultSortDescription
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil//T.entityName
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
            let _ = T.init(entity, viewContext: viewContext, dataStoreManagerInput: self)
        }
    }
    
    func fetchObjects<T: CoreDataProtocol>(predicates: [NSPredicate]) -> [T]? {
        
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        return try? viewContext.fetch(fetchRequest)
    }
    
    @discardableResult
    func getFromCoreDataIfNoSavedNew<T: CoreDataProtocol>(entity: T) -> T {
        return getFromCoreData(entity: entity) ?? T.init(entity, viewContext: viewContext, dataStoreManagerInput: self)
    }
    
    func updateCoreData(entities: [(any CoreDataProtocol)]) {
        
        guard let allObjectsFromCoreData = self.viewContext.fetchObjects(entities.first!.entityName) as? [(any CoreDataProtocol)] else { return
        }
        
        let newObjects = entities.filter { fetchObject(entity: $0) == nil }
        
        ///create new
        newObjects.forEach {
            getFromCoreDataIfNoSavedNew(entity: $0)
        }
        
        let removedObjects = allObjectsFromCoreData.filter { object in
            entities.filter { $0.id == object.id }.first == nil
        }
        
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
        save()
    }
}

//MARK: - Private Methods
extension DataStoreManager {
    
    func initAbstractObjects<T: NSManagedObject>(for objects: Set<T>) -> [T] {
        return objects.map { initAbstractObject(for: $0) }
    }
    
    func initAbstractObject<T: NSManagedObject>(for object: T) -> T {
        if let object = NSManagedObject.init(object) as? T {
            return object
        }
        fatalError()
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
                    save()
                } else if let set = item.value(forKey: key) as? Set<T> {
                    let set = set.filter { $0.objectID != checkItem.objectID }
                    item.setValue(set, forKey: key)
                    save()
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
                    save()
                }
            }
            
            viewContext.delete(item)
            save()
        }
    }
}
