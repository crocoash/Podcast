//
//  MyScreenEdgePanGestureRecognizer.swift
//  Podcasts
//
//  Created by Anton on 19.03.2024.
//

import UIKit

class MyScreenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer, IGestureRecognizer {
    
    var info: Any?
    
    required init(target: Any?, action: Selector?, info : Any?) {
        self.info = info
        super.init(target: target, action: action)
    }
}
