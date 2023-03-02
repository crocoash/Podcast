//
//  CoreDataProtocol.swift
//  Podcasts
//
//  Created by Anton on 23.02.2023.
//

import CoreData

protocol CoreDataProtocol: NSManagedObject {
    
    associatedtype T: NSManagedObject, Identifiable
    func remove()
    static var allObjectsFromCoreData: [T] { get }
    
    func removeFromCoreData()
    func saveInCoredataIfNotSaved()
    func getFromCoreData() -> T?
    func getFromCoreDataIfNoSavedNew() -> T
    
    static func removeAllFromCoreData()
}

protocol NsManagedTableViewProtocol: CoreDataProtocol {
    
    static var fetchResultController: NSFetchedResultsController<T> { get }
    static func getObject(by indexPath: IndexPath)  -> T
    static func getIndexPath(id: NSNumber?) -> IndexPath?
    
    var getIndexPath:IndexPath? { get }
}

protocol FirebaseProtocol: CoreDataProtocol where T: Codable {
    
    var key: String { get }
    func removeFromFireBase(key: String)
    func saveInFireBase()
    static func updateFromFireBase(completion: ((Result<[T]>) -> Void)?)
}
