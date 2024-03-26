//
//  MyError+enum Auth {         case error(AlertData)         case errorEmail(AlertData)         case errorPassword(AlertData)     }.swift
//  Podcasts
//
//  Created by Anton on 19.03.2024.
//

import UIKit

extension MyError {
    
    enum Auth: ERR {
        
        case error(Error)
        case errorEmail(Error)
        case errorPassword(Error)
                
        enum HandlerType {
            case Ok
            case No
            case Yes
        }
        
        func showAlert(vc: UIViewController?, completion: Handler?) {
            guard let vc = vc else { return }
            switch self {
            case .error(let error):
                Alert().create(for: vc, title: "Auth error", message: error.localizedDescription) { _ in
                    [UIAlertAction(title: "Ok", style: .cancel, handler: { _ in completion?(.Ok)})]
                }
            case .errorEmail(let error):
                Alert().create(for: vc, title: "errorEmail", message: error.localizedDescription) { _ in
                    [UIAlertAction(title: "Ok", style: .cancel, handler: { _ in completion?(.Ok)})]
                }
                
            case .errorPassword(let error):
                Alert().create(for: vc, title: "errorPassword", message: error.localizedDescription) { _ in
                    [UIAlertAction(title: "Ok", style: .cancel, handler: { _ in completion?(.Ok)})]
                }
            }
        }
    }
}
