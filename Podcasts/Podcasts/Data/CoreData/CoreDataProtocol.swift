//
//  CoreDataProtocol.swift
//  Podcasts
//
//  Created by Anton on 23.02.2023.
//

import CoreData

protocol CoreDataProtocol: NSManagedObject {
    
    associatedtype T: NSManagedObject, Identifiable
    
    static var allObjectsFromCoreData: [T] { get }
    
    func removeFromCoreDataWithOwnEntityRule()
    func saveInCoredataIfNotSaved()
    var getFromCoreData: T? { get }
    var getFromCoreDataIfNoSavedNew: T { get }
    
    func remove()
    static func removeAll()
}

//protocol NsManagedTableViewProtocol: CoreDataProtocol {
//    
//    static var fetchResultController: NSFetchedResultsController<T> { get }
//    static func getObject(by indexPath: IndexPath)  -> T
//    static func getIndexPath(id: NSNumber?) -> IndexPath?
//    
//    var getIndexPath:IndexPath? { get }
//}

protocol FirebaseProtocol: CoreDataProtocol where T: Codable {
    
    var firebaseKey: String { get }
    func removeFromFireBase(key: String)
    func saveInFireBase()
    static func updateFromFireBase(completion: ((Result<[T]>) -> Void)?)
}
