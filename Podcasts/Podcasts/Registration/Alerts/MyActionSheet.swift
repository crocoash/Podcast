//
//  MyActionSheet.swift
//  MovieApp
//
//  Created by Tsvetkov Anton on 26.10.2021.
//

import UIKit

class MyActionSheet {
    static func create(for view: UIView, title: String?, message: String?, actions: (() -> ([UIAlertAction]))?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        view.present(alertController, animated: true) {
            alertController.view.superview?.isUserInteractionEnabled = true
            alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapGesture)))
        }
//        if let actions = actions { actions().indices.forEach { alertController.addAction(actions()[$0]) }}
    }
    
    static func create(for view: UIView, title: String, actions: ( () -> ([UIAlertAction]))? ) {
        create(title: title, message: nil, actions: actions)
    }
    
    static func create(for view: UIView, title: String) {
        create(title: title, actions: nil)
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            view.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc static func tapGesture(sender: UITapGestureRecognizer) {
        view.dismiss(animated: true, completion: nil)
    }
}
