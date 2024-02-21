//
//  MyaddGestureRecognizer.swift
//  MovieApp
//
//  Created by Tsvetkov Anton on 02.08.2021.
//

import UIKit

extension UIView {
    func addMyGestureRecognizer(_ target: Any?, type gesture: TypeOfGestureRecognizer,_ selector: Selector, info: Any? = nil) {
        self.isUserInteractionEnabled = true
        // get array of GestureRecognizer then add him to the View
        gesture.createGestures(for: target, selector: selector, info: info).forEach { addGestureRecognizer($0) }
    }
    
    func addMyGestureRecognizer(_ target: Any?, type gestures: [TypeOfGestureRecognizer],_ selector: Selector) {
        self.isUserInteractionEnabled = true
        // get array of GestureRecognizer then add him to the View
        gestures.forEach {
            $0.createGestures(for: target, selector: selector).forEach { addGestureRecognizer($0) }

        }
    }
}

extension Collection where Element: UIView {
    func myAddGestureRecogniser(_ target: Any, type gesture: TypeOfGestureRecognizer, selector: Selector)  {
        forEach {
            $0.isUserInteractionEnabled = true
            $0.addMyGestureRecognizer(target, type: gesture, selector)
        }
    }
}

extension UIViewController {
    func addMyGestureRecognizer(_ target: Any?, type gesture: TypeOfGestureRecognizer, _ selector: Selector) {
        view.addMyGestureRecognizer(target, type: gesture, selector)
    }
}

@objc protocol IGestureRecognizer where Self: UIGestureRecognizer {
    var info: Any? { get set }
    init(target: Any?, action: Selector?, info: Any?)
}

enum TypeOfGestureRecognizer {
    case tap(_ countOfTouches: Int = 1)
    case swipe(directions: [UISwipeGestureRecognizer.Direction] = Direction.round)
    case longPressGesture(minimumPressDuration: TimeInterval = 0.5)
    case screenEdgePanGestureRecognizer(directions: [UIRectEdge])
    case panGestureRecognizer
    
    func createGestures(for target: Any?, selector: Selector?, info: Any? = nil) -> [any IGestureRecognizer] {
        
        switch self {
        
        //tap
        case .tap(let count) :
            let tap = MyTapGestureRecognizer(target: target, action: selector, info: info)
            tap.numberOfTapsRequired = count
            return [tap]
            
        //swipe
        case .swipe(let directions):
            var gestures = [any IGestureRecognizer]()
            directions.forEach {
                    let swipe = MySwipeGestureRecognizer(target: target, action: selector, info: info)
                    swipe.direction = $0
                    gestures.append(swipe)
            }
            return gestures
            
        //longPressGesture
        case .longPressGesture(let minimumPressDuration):
            let gesture = MyLongPressGestureRecognizer(target: target, action: selector, info: info)
            gesture.minimumPressDuration = minimumPressDuration
            return [ gesture ]
        
        //screenEdgePanGestureRecognizer
        case .screenEdgePanGestureRecognizer(let directions) :
            var gestures = [any IGestureRecognizer]()
            directions.forEach { 
                let screenEdgePan = MyScreenEdgePanGestureRecognizer(target: target, action: selector, info: info)
                screenEdgePan.edges = $0
                gestures.append(screenEdgePan)
            }
            return gestures
           
        // panGestureRecognizer
        case .panGestureRecognizer:
            return [MyPanGestureRecognizer(target: target, action: selector, info: info)]
        }
    }
}

enum Direction {
    static var round: [UISwipeGestureRecognizer.Direction] {
        [.down,.left,.right,.up]
    }
}

class MyPanGestureRecognizer: UIPanGestureRecognizer, IGestureRecognizer {
    
    var info: Any?
    
    required init(target: Any?, action: Selector?, info : Any?) {
        self.info = info
        super.init(target: target, action: action)
    }
}

class MyScreenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer, IGestureRecognizer {
    
    var info: Any?
    
    required init(target: Any?, action: Selector?, info : Any?) {
        self.info = info
        super.init(target: target, action: action)
    }
}

class MyTapGestureRecognizer: UITapGestureRecognizer, IGestureRecognizer {
    
    var info: Any?
    
    required init(target: Any?, action: Selector?, info : Any?) {
        self.info = info
        super.init(target: target, action: action)
    }
}

class MySwipeGestureRecognizer: UISwipeGestureRecognizer, IGestureRecognizer {
    
    var info: Any?
    
    required init(target: Any?, action: Selector?, info : Any?) {
        self.info = info
        super.init(target: target, action: action)
    }
}

