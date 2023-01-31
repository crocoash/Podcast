//
//  MyError.swift
//  Podcasts
//
//  Created by Anton on 30.01.2023.
//

import UIKit

enum Result<T> {
    case success(result: T)
    case failure(error: MyError)
}

enum MyError: Error, Equatable {
    case noData
    case noInternetConnection
    case error(String)
    
    func showAlert(vc: UIViewController?) {
        
        guard let vc = vc else { return }
        
        switch self {
            
        case .noInternetConnection:
            Alert().create(title: "No Internet Connection") { _ in
                return [UIAlertAction(title: "Ok", style: .cancel) { _ in
                    vc.dismiss(animated: true)
                }]
            }
            
        case .noData :
            Alert().create(title: "") { _ in
                return [UIAlertAction(title: "Ok", style: .cancel) { _ in
                    vc.dismiss(animated: true)
                }]
            }
            
        case .error(let error) :
            Alert().create(title: error) { _ in
                return [UIAlertAction(title: "Ok     ", style: .cancel) { _ in
                    vc.dismiss(animated: true)
                }]
            }
        }
    }
}
