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
//    case noInternetConnection
    case error(String)
    
    func showAlert(vc: UIViewController?, tittle: String? = nil, completion: (() -> Void)? = nil) {
        
        guard let vc = vc else { return }
        
        switch self {
//            
//        case .noInternetConnection:
//            Alert().create(vc: vc, title: "No Internet Connection") { _ in
//                return [UIAlertAction(title: "Ok", style: .cancel) ]
//            }
//            
        case .noData :
            
            Alert().create(for: vc, title: tittle ?? "") { _ in
                return [UIAlertAction(title: "Ok", style: .cancel) ]
            }
            
        case .error(let error) :
            
            Alert().create(for: vc, title: tittle, message: error) { _ in
                return [UIAlertAction(title: "Ok", style: .cancel) { _ in
                    completion?()
                } ]
            }
        }
    }
}
