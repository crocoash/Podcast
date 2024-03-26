//
//  FireBaseError.swift
//  Podcasts
//
//  Created by Anton on 19.03.2024.
//

import UIKit

//MARK: FirebaseDatabase
extension MyError {
    
    enum FirebaseDatabase: ERR {
        
        case error(Error)
        case snapShotIsNil
        
        enum HandlerType {
            case Ok
            case No
            case Yes
        }
        
        func showAlert(vc: UIViewController?, completion: Handler?) {
            
            guard let vc = vc else { return }
            
            switch self {
        
            case .snapShotIsNil:
                Alert().create(for: vc, title: "FirebaseDatabase error", message: "snapShotIsNil") { _ in
                    [UIAlertAction(title: "Ok", style: .cancel, handler: { _ in completion?(.Ok)})]
                }
                
            case .error(let error):
                Alert().create(for: vc, title: "FirebaseDatabase error", message: error.localizedDescription) { _ in
                    [
                        UIAlertAction(title: "No", style: .cancel, handler: { _ in completion?(.No)}),
                        UIAlertAction(title: "Yes", style: .default, handler: { _ in completion?(.Yes)})
                    ]
                }
            }
        }
    }
}
