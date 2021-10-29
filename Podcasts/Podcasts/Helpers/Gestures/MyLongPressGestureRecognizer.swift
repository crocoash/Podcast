//
//  LongPress.swift
//  MovieApp
//
//  Created by Tsvetkov Anton on 22.07.2021.
//

import UIKit

struct MyLongPressGestureRecognizer {
    private let object: Any?
    private var minimumPressDuration: TimeInterval
    
    init(object: Any?, minimumPressDuration: TimeInterval = 0.5) {
        self.object = object
        self.minimumPressDuration = minimumPressDuration
    }
    
    func createLongPressGR (action: Selector?) -> UILongPressGestureRecognizer {
        let longPressGR = UILongPressGestureRecognizer(target: object, action: action)
        longPressGR.minimumPressDuration = minimumPressDuration
        return longPressGR
    }
    
    //For UITableViewCell
    static func createSelector<Cell: UITableViewCell>(for longPressGR: UILongPressGestureRecognizer, completion: (Cell) -> ()) {
        guard let cell = longPressGR.view as? Cell else { return }
        if longPressGR.state == .began {
            completion(cell)
            feedbackGenerator(for: longPressGR)
        }
    }
    
    //For UICollectionViewCell
    static func createSelector<Cell: UICollectionViewCell>(for longPressGR: UILongPressGestureRecognizer, completion: (Cell) -> ())   {
        guard let cell = longPressGR.view as? Cell else { return }
        if longPressGR.state == .began {
            completion(cell)
            feedbackGenerator(for: longPressGR)
        }
    }
    
    static func createSelector(for longPressGR: UILongPressGestureRecognizer, completion: () -> ())   {
        if longPressGR.state == .began {
            completion()
            feedbackGenerator(for: longPressGR)
        }
    }
    
    private static func feedbackGenerator(for longPressGR: UILongPressGestureRecognizer) {
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
}

