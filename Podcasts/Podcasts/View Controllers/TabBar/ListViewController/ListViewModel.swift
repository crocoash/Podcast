//
//  ListViewModel.swift
//  Podcasts
//
//  Created by Anton on 11.08.2023.
//

import Foundation
import CoreData

class ListViewModel: IPerRequest, INotifyOnChanged {
   
   struct Arguments {}
   
   //MARK: services
   private let favouriteManager: FavouriteManager
   private let listeningManager: ListeningManager
   private let likeManager:      LikeManager
   
   private let favouriteTableViewVM: FavouriteTableViewModel
   var isLoading: Bool { favouriteTableViewVM.isUpdating }
   
   //MARK: Init
   required init(container: IContainer, args: Arguments) {
      self.favouriteManager = container.resolve()
      self.listeningManager = container.resolve()
      self.likeManager = container.resolve()
      self.favouriteTableViewVM = container.resolve(args: FavouriteTableViewModel.Arguments.init())
      
      favouriteTableViewVM.changed.subscribe(self) { `self`, _ in
         `self`.changed.raise()
      }
   }
}

extension ListViewModel {

   func changeSearchedSection(selectedScope: Int) {
      let index = selectedScope == 0 ? nil : selectedScope - 1
      Task { await favouriteTableViewVM.changeSearchedSection(searchedSection: index) }
   }
   
   func performSearch(text: String?) {
      favouriteTableViewVM.performSearch(text)
   }
   
   func cancelSearching() {
      Task { await favouriteTableViewVM.cancelSearching() }
   }
   
   func removeAll() {
      favouriteManager.removeAll()
      listeningManager.removeAll()
      likeManager.removeAll()
   }
   
   func scopeBar() -> (titles: [String], selectIndex: Int)? {
      if !favouriteTableViewVM.isEmpty {
         var titles = favouriteTableViewVM.searchedSections
         titles.insert("All", at: .zero)
         var selectIndex = 0
         if let index = favouriteTableViewVM.searchedSectionIndex {
            selectIndex = index + 1
         }
         return (titles: titles, selectIndex: selectIndex)
      }
      return nil
   }

   func isSearchControllerIsHidden() -> Bool {
      return isEmptyTableView
   }
   
   func isNavigationItemIsHidden() -> Bool {
      return isEmptyTableView
   }
   
   func getViewModelForTableView() -> FavouriteTableViewModel {
      return favouriteTableViewVM
   }
}

extension ListViewModel {
   
   private var isEmptyTableView: Bool {
      return favouriteTableViewVM.isEmpty && !favouriteTableViewVM.isSearching
   }
}
