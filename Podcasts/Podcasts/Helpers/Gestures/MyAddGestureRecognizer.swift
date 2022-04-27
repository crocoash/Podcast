//
//  MyaddGestureRecognizer.swift
//  MovieApp
//
//  Created by Tsvetkov Anton on 02.08.2021.
//

import UIKit

extension UIView {
    func addMyGestureRecognizer(_ target: Any?,type gesture: TypeOfGestureRecognizer, selector: Selector) {
        self.isUserInteractionEnabled = true
        // get array of GestureRecognizer then add him to the View
        gesture.createGestures(for: target, selector: selector).forEach { addGestureRecognizer($0) }
    }
}

extension Collection where Element: UIView {
    func myAddGestureRecogniser(_ target: Any,type gesture: TypeOfGestureRecognizer, selector: Selector)  {
        forEach {
            $0.isUserInteractionEnabled = true
            $0.addMyGestureRecognizer(target, type: gesture, selector: selector)
        }
    }
}

extension UIViewController {
    func addMyGestureRecognizer(_ target: Any?, type gesture: TypeOfGestureRecognizer, _ selector: Selector) {
        view.addMyGestureRecognizer(target, type: gesture, selector: selector)
    }
}

enum TypeOfGestureRecognizer {
    case tap(_ countOfTouches: Int = 1)
    case swipe(directions: [UISwipeGestureRecognizer.Direction] = Direction.round)
    case longPressGesture(minimumPressDuration: TimeInterval = 0.5)
    case screenEdgePanGestureRecognizer(directions: [UIRectEdge])
    
    func createGestures(for target: Any?, selector: Selector?) -> [UIGestureRecognizer] {
        
        switch self {
        
        //tap
        case .tap(let count) :
            let tap = UITapGestureRecognizer(target: target, action: selector)
            tap.numberOfTapsRequired = count
            return [tap]
            
        //swipe
        case .swipe(let directions):
            var gestures = [UIGestureRecognizer]()
            directions.forEach {
                    let swipe = UISwipeGestureRecognizer(target: target, action: selector)
                    swipe.direction = $0
                    gestures.append(swipe)
            }
            return gestures
            
        //longPressGesture
        case .longPressGesture(let minimumPressDuration): return [
            MyLongPressGestureRecognizer(object: target, minimumPressDuration: minimumPressDuration)
                        .createLongPressGR(action: selector)
            ]
        
        //screenEdgePanGestureRecognizer
        case .screenEdgePanGestureRecognizer(let directions) :
            var gestures = [UIGestureRecognizer]()
            directions.forEach { 
                let screenEdgePan = UIScreenEdgePanGestureRecognizer(target: target, action: selector)
                screenEdgePan.edges = $0
                gestures.append(screenEdgePan)
            }
            return gestures
        }
        
    }
}

enum Direction {
    static var round: [UISwipeGestureRecognizer.Direction] {
        [.down,.left,.right,.up]
    }
}
