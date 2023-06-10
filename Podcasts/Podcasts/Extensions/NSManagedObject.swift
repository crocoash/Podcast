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
    
    static var viewContext: NSManagedObjectContext { DataStoreManager.shared.viewContext }
    var viewContext: NSManagedObjectContext { DataStoreManager.shared.viewContext }
    static var backGroundContext: NSManagedObjectContext { DataStoreManager.shared.backgroundContext }
    
    
    func mySave() {
        viewContext.mySave()
    }
    
    //    func remove() {
    //        if let self = self as? (any CoreDataProtocol) {
    //            if let self = self as? (any FirebaseProtocol)  {
    //                let key = self.firebaseKey
    //                self.removeFromCoreDataWithOwnEntityRule()
    ////                self.removeFromFireBase(key: key)
    //            } else {
    //                self.removeFromCoreDataWithOwnEntityRule()
    //            }
    //            saveCoreData()
    //        } else {
    //            fatalError()
    //        }
    //    }
    
//    func remove() {
//
//    propertyLoop: for selfKey in self.entity.propertiesByName.keys {
//        let selfValue: Any? = self.value(forKey: selfKey)
//
//            if let subItem = selfValue as? NSManagedObject {
//
//                let subItemKeys = subItem.entity.propertiesByName.keys
//
//                for subItemKey in  subItemKeys {
//
//                    let subItemValue = subItem.value(forKey: subItemKey)
//
//                    if let _ = subItemValue as? Self.Type {
//                        subItem.setValue(nil, forKey: subItemKey)
//                        continue propertyLoop
//                    } else if var array = subItemValue as? [Self] {
//                        if let index = array.firstIndex(of: self) {
//                            let newarray = array.remove(at: index)
//                            subItem.setValue(newarray, forKey: subItemKey)
//                        }
//                        continue propertyLoop
//                    }
//                }
//                subItem.remove()
//            }
//        }
//        viewContext.delete(self)
//        mySave()
//    }
}

extension NSManagedObject {
  var convert: [String: Any]? {
    if let self = self as? Encodable {
      if let data = try? JSONEncoder().encode(self) {
        if let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
          return result
        }
      }
    }
    return nil
  }
}




