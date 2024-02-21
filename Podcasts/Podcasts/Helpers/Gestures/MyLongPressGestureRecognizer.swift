//
//  LongPress.swift
//  MovieApp
//
//  Created by Tsvetkov Anton on 22.07.2021.
//

import UIKit

class MyLongPressGestureRecognizer: UILongPressGestureRecognizer, IGestureRecognizer {
    var info: Any?
    
    required init(target: Any?, action: Selector?, info: Any?) {
        self.info = info
        
        super.init(target: target, action: action)
        
    }
    //For UITableViewCell
    static func createSelector<Cell: UITableViewCell>(for longPressGR: UILongPressGestureRecognizer, completion: (Cell) -> ()) {
        guard let cell = longPressGR.view as? Cell,
              longPressGR.state == .began else { return }
        
        completion(cell)
    }
    
    //For UICollectionViewCell
    static func createSelector<Cell: UICollectionViewCell>(for longPressGR: UILongPressGestureRecognizer, completion: (Cell) -> ())   {
        guard let cell = longPressGR.view as? Cell,
              longPressGR.state == .began else { return }
        
        completion(cell)
    }
}

