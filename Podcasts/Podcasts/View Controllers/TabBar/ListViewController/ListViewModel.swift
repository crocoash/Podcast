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
   
   //MARK: Init
   required init(container: IContainer, args: Arguments) {
      self.favouriteManager = container.resolve()
      self.listeningManager = container.resolve()
      self.likeManager = container.resolve()
      self.favouriteTableViewVM = container.resolve(args: FavouriteTableViewModel.Arguments.init())
      
      favouriteTableViewVM.changed.subscribe(self) { this, _ in
         this.changed.raise()
      }
   }
   
   lazy var sectionCountChanged: (() -> (Int)) = { [weak self] in
      guard let self = self else { return 0 }
      return favouriteTableViewVM.numbersOfSections
   }

   func changeSearchedSection(selectedScope: Int) {
      let index = selectedScope == 0 ? nil : selectedScope - 1
      favouriteTableViewVM.changeSearchedSection(searchedSection: index)
   }
   
   func performSearch(text: String?) {
      favouriteTableViewVM.performSearch(text)
   }
   
   func cancelSearching() {
      favouriteTableViewVM.cancelSearching()
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
      } else {
         return nil
      }
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
