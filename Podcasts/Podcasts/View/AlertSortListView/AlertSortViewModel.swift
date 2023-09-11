//
//  AlertSortViewModel.swift
//  Podcasts
//
//  Created by Anton on 10.09.2023.
//

import Foundation

class AlertSortListViewModel {
   
   private let dataStoreManager: DataStoreManager
   private let listDataManager: ListDataManager
   
   init(dataStoreManager: DataStoreManager, listDataManager: ListDataManager) {
      self.dataStoreManager = dataStoreManager
      self.listDataManager = listDataManager
   }
   
   var listSections: [ListSection]  {
      return dataStoreManager.viewContext.fetchObjectsArray(ListSection.self,
                                                            sortDescriptors: [NSSortDescriptor(key: #keyPath(ListSection.sequenceNumber), ascending: true)])
   }
   
   var countOfRows: Int {
      return listSections.count
   }
   
   func moveItem(from oldIndex: Int, to newIndex: Int) {
      let object = listSections[oldIndex]
      listDataManager.change(for: object, sequenceNumber: newIndex)
   }
   
   func getItem(for indexPath: IndexPath) -> ListSection {
      return listSections[indexPath.row]
   }
   
   func changeActiveState(for indexPath: IndexPath) {
      let listSection = getItem(for: indexPath)
      listDataManager.changeActiveState(for: listSection)
   }
}
