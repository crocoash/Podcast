//
//  MyAlert.swift
//  MovieApp
//
//  Created by Tsvetkov Anton on 26.10.2021.
//

import UIKit

class MyAlert {
    static func create(for view: UIView, title: String?, message: String?, actions: (Void -> ([UIAlertAction]))? ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        view.present(alertController, animated: true) {
            alertController.view.superview?.isUserInteractionEnabled = true
            alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapGesture)))
        }
        
        if let actions = actions { actions().forEach { alertController.addAction($0) }  }
    }
    
    static func create(title: String, actions: ( () -> ([UIAlertAction]))? ) {
        create(title: title, message: nil, actions: actions)
    }
    
    static func create(for view: UIView, title: String, withTimeIntervalToDismiss timeInterval: TimeInterval) {
        create(title: title, actions: nil)
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            view.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc static func tapGesture(for view: UIView, sender: UITapGestureRecognizer) {
        superview.dismiss(animated: true)
    }
}



