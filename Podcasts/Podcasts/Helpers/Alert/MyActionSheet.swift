//
//  MyActionSheet.swift
//  MovieApp
//
//  Created by Tsvetkov Anton on 26.10.2021.
//

import UIKit

class MyActionSheet {
    
    static func create(for vc: UIViewController, title: String?, message: String?, actions: (() -> ([UIAlertAction]))?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        vc.present(alertController, animated: true) {
            alertController.view.superview?.isUserInteractionEnabled = true
            alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapGesture)))
        }
        
        if let actions = actions { actions().forEach { alertController.addAction($0) }}
        
    }
    
    static func create(for vc: UIViewController, title: String, actions: ( () -> ([UIAlertAction]))? ) {
        create(for: vc, title: title, message: nil, actions: actions)
    }
    
    static func create(for vc: UIViewController, title: String) {
        create(for: vc, title: title, actions: nil)
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            vc.dismiss(animated: true)
        }
    }
}

extension MyActionSheet {
    
    @objc static func tapGesture(vc: UIViewController, sender: UITapGestureRecognizer) {
        vc.dismiss(animated: true)
    }
}
