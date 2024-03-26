//
//  MyError+ApiService.swift
//  Podcasts
//
//  Created by Anton on 19.03.2024.
//

import UIKit

extension MyError {
    
    enum ApiService: ERR {
        
        case noData
        case error(Error)
        case responseError
        case urlError
        
        enum HandlerType {
            case Ok
        }
        
        func showAlert(vc: UIViewController?, completion: Handler?) {
            
            guard let vc = vc else { return }
            
            switch self {
            case .noData :
                Alert().create(for: vc, title: "ApiService no Data", message: "no data") { _ in
                    return [UIAlertAction(title: "Ok", style: .cancel, handler: { _ in completion?(.Ok) })]
                }
                
            case .error(let error):
                Alert().create(for: vc, title: "ApiService error", message: error.localizedDescription) { _ in
                    return [UIAlertAction(title: "Ok", style: .cancel, handler: { _ in completion?(.Ok) })]
                }
                
            case .responseError:
                Alert().create(for: vc, title: "ApiService response Error", message: "") { _ in
                    return [UIAlertAction(title: "Ok", style: .cancel, handler: { _ in completion?(.Ok) })]
                }
            case .urlError:
                Alert().create(for: vc, title: "ApiService url rrror", message: "") { _ in
                    return [UIAlertAction(title: "Ok", style: .cancel, handler: { _ in completion?(.Ok) })]
                }
            }
        }
    }
}
