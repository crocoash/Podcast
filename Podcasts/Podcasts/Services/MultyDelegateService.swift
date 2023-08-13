//
//  MultyDelegateService.swift
//  Podcasts
//
//  Created by Anton on 09.08.2023.
//

import Foundation

//MARK: - Input
protocol MultyDelegateServiceInput: AnyObject {
    var delegate: AnyObject? { get set }
}

class MultyDelegateService<T>: NSObject, MultyDelegateServiceInput {
    
    private let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    
    var delegate: AnyObject? {
        get {
            return nil
        }
        
        set {
            guard let delegate = newValue else { return }
            add(delegate: delegate)
        }
    }
    
    private func add<C>(delegate: C) {
        if let delegate = delegate as? T {
            delegates.add(delegate as AnyObject)
        } else {
            fatalError("delegate must be like \(T.self)")
        }
    }
    
    func delegates(_ delegate: (T) -> ()) {
        delegates.allObjects.reversed().forEach {
            delegate($0 as! T)
        }
    }
}
