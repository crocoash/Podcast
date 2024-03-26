//
//  MySwipeGestureRecognizer.swift
//  Podcasts
//
//  Created by Anton on 19.03.2024.
//

import UIKit

class MySwipeGestureRecognizer: UISwipeGestureRecognizer, IGestureRecognizer {
    
    var info: Any?
    
    required init(target: Any?, action: Selector?, info : Any?) {
        self.info = info
        super.init(target: target, action: action)
    }
}
