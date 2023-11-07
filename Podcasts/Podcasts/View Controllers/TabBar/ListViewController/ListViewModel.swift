//
//  ListViewModel.swift
//  Podcasts
//
//  Created by Anton on 11.08.2023.
//

import Foundation
import CoreData

class ListViewModel: IPerRequest, INotifyOnChanged {
  
   typealias Arguments = Void

   let favouriteTableViewVM: FavouriteTableViewModel
   
   //MARK: Init
   required init(container: IContainer, args: Arguments) {
      self.favouriteTableViewVM = container.resolve()
      
      favouriteTableViewVM.changed.subscribe(self) { this, _ in
         this.changed.raise()
      }
   }
   
   lazy var sectionCountChanged: (() -> (Int)) = { [weak self] in
      guard let self = self else { return 0 }
      return favouriteTableViewVM.numbersOfSections
   }

   func performSearch(text: String?) {
      favouriteTableViewVM.performSearch(text)
   }
}
