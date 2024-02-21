//
//  Alert.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 27.10.2021.
//

import UIKit

protocol AlertDelegate: AnyObject {
    func alertEndShow(_ alert: Alert)
    func alertShouldShow(_ alert: Alert, alertController: UIAlertController)
}

class Alert {
    
    weak var delegate: AlertDelegate?
    
    func create(for vc: UIViewController, title: String?, message: String?, actions: ((String) -> [UIAlertAction])? ) {
        create(for: vc, title: title, message: message, actions: actions, configureTextField: nil)
    }
    
    func create(for vc: UIViewController, title: String, actions: ((String) -> [UIAlertAction])? ) {
        create(for: vc, title: title, message: nil, actions: actions)
    }
    
    func create(vc: UIViewController, title: String, withTimeIntervalToDismiss timeInterval: TimeInterval) {
        create(for: vc, title: title, actions: nil)
        
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            vc.dismiss(animated: true)
        }
    }
    
    func create(for vc: UIViewController, title: String?, message: String?, actions: ((String) -> ([UIAlertAction]))?, configureTextField: ((UITextField) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let configureTextField = configureTextField {
            alertController.addTextField { textfield in
                configureTextField(textfield)
            }
            
            if let actions = actions {
                if let textFields = alertController.textFields, !textFields.isEmpty, let text = textFields.first?.text {
                    actions(text).forEach { alertController.addAction($0) }
                }
            }
        } else {
            if let actions = actions {
                actions("").forEach { alertController.addAction($0) }
            }
        }
                
        vc.present(alertController, animated: true)
    }
}
