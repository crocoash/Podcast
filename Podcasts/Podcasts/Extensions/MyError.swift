//
//  MyError.swift
//  Podcasts
//
//  Created by Anton on 30.01.2023.
//

import UIKit

enum Result<T> {
    case success(result: T)
    case failure(MyError)
}

enum MyError {
    
    case apiService(ApiService)
    case downloadService(DownloadService)
    case firebaseDatabase(FirebaseDatabase)
    
    
    func showAlert(vc: UIViewController?, completion: (() -> Void)? = nil) {
        
        switch self {
            
        case .apiService(let apiService):
            apiService.showAlert(vc: vc, completion: completion)

        case .downloadService(let downloadService):
            downloadService.showAlert(vc: vc, completion: completion)

        case .firebaseDatabase(let firebaseDatabase):
            firebaseDatabase.showAlert(vc: vc, completion: completion)
        }
    }

    
    enum ApiService {
        
        case noData
        case error(String)
        
        func showAlert(vc: UIViewController?, completion: (() -> Void)? = nil) {
            
            guard let vc = vc else { return }
            
            switch self {
            case .noData :
                
                Alert().create(for: vc, title: "ApiService error", message: "No data") { _ in
                    return [UIAlertAction(title: "Ok", style: .cancel) ]
                }
                
            case .error(let error) :
                Alert().create(for: vc, title: "ApiService error", message: error) { _ in
                    return [UIAlertAction(title: "Ok", style: .cancel) { _ in
                        completion?()
                    } ]
                }
            }
        }
    }
    
    enum DownloadService {

        case noInternetConnection
        case internerTypeCellular(String)
        case cannotRemove(NSError)
        
        func showAlert(vc: UIViewController?, completion: (() -> Void)? = nil) {
            
            guard let vc = vc else { return }
            
            switch self {
            case .noInternetConnection:
                Alert().create(for: vc, title: "Download error", message: "No Internet") { _ in
                    [UIAlertAction(title: "Ok", style: .cancel) { _ in
                        completion?()
                    }]
                }
            case .internerTypeCellular(let error):
                Alert().create(for: vc, title: "Download error", message: error) { _ in
                    [ UIAlertAction(title: "No", style: .cancel) { _ in
                        return
                    }, UIAlertAction(title: "Yes", style: .default) { _ in
                        completion?()
                    }]
                }
            case .cannotRemove(let error):
                Alert().create(for: vc, title: "Download error", message: error.localizedDescription) { _ in
                    [ UIAlertAction(title: "No", style: .cancel) { _ in
                        completion?()
                        return
                    }, UIAlertAction(title: "Yes", style: .default) { _ in
                        completion?()
                    }]
                }
            }
        }
    }
    
    enum FirebaseDatabase {
        case error(Error)
        case NSNull
        case snapShotIsNil
        
        func showAlert(vc: UIViewController?, completion: (() -> Void)? = nil) {
            
            guard let vc = vc else { return }
            
            switch self {
            case .NSNull:
                Alert().create(for: vc, title: "FirebaseDatabase error", message: "No Internet") { _ in
                    [UIAlertAction(title: "Ok", style: .cancel) { _ in
                        completion?()
                    }]
                }
            case .snapShotIsNil:
                Alert().create(for: vc, title: "FirebaseDatabase error", message:"snapShotIsNil") { _ in
                    [UIAlertAction(title: "Ok", style: .cancel) { _ in
                        completion?()
                    }]
                }
            case .error(let error):
                Alert().create(for: vc, title: "FirebaseDatabase error", message: error.localizedDescription) { _ in
                    [UIAlertAction(title: "No", style: .cancel) { _ in
                        completion?()
                        return
                    }, UIAlertAction(title: "Yes", style: .default) { _ in
                        completion?()
                    }]
                }
            }
        }
    }
}
