//
//  Alert.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 27.10.2021.
//

import UIKit

protocol AlertDelegate: AnyObject {
    func alertEndShow(_ alert: MyAlert)
    func alertShouldShow(_ alert: MyAlert, alertController: UIAlertController)
}

class MyAlert {
    
    weak var delegate: AlertDelegate?
    
    func create(title: String?, message: String?, actions: ((String) -> [UIAlertAction])? ) {
        create(title: title, message: message, actions: actions, configureTextField: nil)
    }
    
    func create( title: String, actions: ((String) -> [UIAlertAction])? ) {
        create(title: title, message: nil, actions: actions)
    }
    
    func create(title: String, withTimeIntervalToDismiss timeInterval: TimeInterval) {
        create(title: title, actions: nil)
        
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.delegate?.alertEndShow(self!)
        }
    }
    
    func create(title: String?, message: String?, actions: ((String) -> ([UIAlertAction]))?, configureTextField: ((UITextField) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let configureTextField = configureTextField {
            alertController.addTextField { textfield in
                configureTextField(textfield)
            }
        }
        
        if let actions = actions {
            guard let textFields = alertController.textFields, !textFields.isEmpty, let text = textFields.first?.text else { return }
            actions(text).forEach { alertController.addAction($0) }
        }
        
        delegate?.alertShouldShow(self, alertController: alertController)
        
    }
}
