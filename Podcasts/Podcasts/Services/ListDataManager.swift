//
//  File.swift
//  Podcasts
//
//  Created by Anton on 24.08.2023.
//

import Foundation
import CoreData

//MARK: - Delegate
protocol ListDataManagerDelegate: AnyObject {
   func listDataManagerDidUpdate(_ ListDataManager: ListDataManager)
}

//MARK: - Input
protocol ListDataManagerInput: MultyDelegateServiceInput {
   func change(for entity: ListSection, sequenceNumber: Int)
   func changeActiveState(for listSection: ListSection)
}

class ListDataManager: MultyDelegateService<ListDataManagerDelegate>, ListDataManagerInput {
   
   private let dataStoreManager: DataStoreManagerInput
   private let firebaseDatabase: FirebaseDatabaseInput
   
   //MARK: init
   init(dataStoreManager: DataStoreManagerInput, firebaseDatabase: FirebaseDatabaseInput) {
      
      self.dataStoreManager = dataStoreManager
      self.firebaseDatabase = firebaseDatabase
      
      super.init()
      
      firebaseDatabase.update(vc: self, viewContext: dataStoreManager.viewContext, type: ListData.self)
      firebaseDatabase.observe(vc: self, viewContext: dataStoreManager.viewContext, type: ListData.self)
   }
   
   func change(for entity: ListSection, sequenceNumber: Int) {
      var listSections = dataStoreManager.viewContext.fetchObjectsArray(ListSection.self, sortDescriptors: [NSSortDescriptor(key: #keyPath(ListSection.sequenceNumber), ascending: true)])
      
      listSections.remove(at: Int(truncating: entity.sequenceNumber))
      listSections.insert(entity, at: sequenceNumber)
      
      for (index, value) in listSections.enumerated() {
         value.sequenceNumber = index as NSNumber
      }
      
      dataStoreManager.save()
      saveListData()
   }
   
   func changeActiveState(for listSection: ListSection) {
      listSection.isActive.toggle()
      dataStoreManager.save()
      saveListData()
   }
}

//MARK: - Private Methods
extension ListDataManager {
   
   private func saveListData() {
      guard let listData = dataStoreManager.viewContext.fetchObjects(ListData.self).first else { return }
      firebaseDatabase.add(entity: listData)
   }
   
   private func configureListData() -> ListData {
      
      let entities = dataStoreManager.viewContext.fetchObjects(ListData.self)
      
      if entities.count > 1 {
         entities.forEach {
            let abstractEntity = dataStoreManager.initAbstractObject(for: $0)
            dataStoreManager.removeFromCoreData(entity: $0)
            firebaseDatabase.remove(entity: abstractEntity)
         }
         return initListData()
      } else if entities.isEmpty {
         let listData = initListData()
         firebaseDatabase.add(entity: listData)
         return listData
      } else if entities.count == 1, let listData = entities.first {
         firebaseDatabase.add(entity: listData)
         return listData
      }
      fatalError()
   }
   
   private func initListData() -> ListData {
      let listeningPodcast = ListSection(entity: ListeningPodcast.self,
                                         nameOfSection: "Listening podcast",
                                         sequenceNumber: 0,
                                         viewContext: dataStoreManager.viewContext)
      dataStoreManager.save()
      let favouritePodcast = ListSection(entity: FavouritePodcast.self,
                                         nameOfSection: "Favourite podcast",
                                         sequenceNumber: 1,
                                         viewContext: dataStoreManager.viewContext)
      dataStoreManager.save()
      let likedMoment = ListSection(entity: LikedMoment.self,
                                    nameOfSection: "Liked moments",
                                    sequenceNumber: 2,
                                    viewContext: dataStoreManager.viewContext)
      dataStoreManager.save()
      let listData = ListData([likedMoment, favouritePodcast, listeningPodcast], viewContext: dataStoreManager.viewContext)
      
      dataStoreManager.save()
      
      firebaseDatabase.add(entity: listData)
      
      return listData
   }
   
   private func updateListData(with listData: ListData) {
      dataStoreManager.updateCoreData(entity: listData, withRelationShip: true)
      dataStoreManager.save()
   }
}

//MARK: - FirebaseDatabaseDelegate
extension ListDataManager: FirebaseDatabaseDelegate {
   
   func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didGetEmptyData type: any FirebaseProtocol.Type) {
      if type is ListData.Type {
         let _ = configureListData()
      }
   }
   
   func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entity: (any FirebaseProtocol)) {
      
   }
   
   func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didRemove entity: (any FirebaseProtocol)) {
      
   }
   
   func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didAdd entities: [any FirebaseProtocol]) {
      if let listsData = entities as? [ListData] {
         if listsData.count > 1 {
            listsData.forEach {
               firebaseDatabase.remove(entity: $0)
            }
         } else {
            guard let listData = listsData.first else { return }
            updateListData(with: listData)
         }
      }
   }
   
   func firebaseDatabase(_ firebaseDatabase: FirebaseDatabase, didUpdate entity: (any FirebaseProtocol)) {

      if let listData = entity as? ListData {
         updateListData(with: listData)
      }
      delegates {
         $0.listDataManagerDidUpdate(self)
      }
   }
}
