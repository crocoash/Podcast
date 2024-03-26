//
//  MyError+PodcastManager.swift
//  Podcasts
//
//  Created by Anton on 19.03.2024.
//

import UIKit

extension MyError {
    
    enum PodcastManager: ERR {
        
        case netWorkError(ApiService)
        case noData(request: String)
        
        enum HandlerType {
            case Ok
        }
        
        func showAlert(vc: UIViewController?, completion: Handler?) {
            guard let vc = vc else { return }
            switch self {
                
            case .netWorkError(let apiError):
                switch apiError {
                case .error(let error):
                    Alert().create(for: vc, title: "PodcastManager error", message: error.localizedDescription) { _ in
                        return [UIAlertAction(title: "Ok", style: .cancel, handler: { _ in completion?(.Ok) })]
                    }
                case .noData:
                
                    Alert().create(for: vc, title: "No data", message: "") { _ in
                        return [UIAlertAction(title: "Ok", style: .cancel, handler: { _ in completion?(.Ok) }) ]
                    }
                case .responseError:
                    Alert().create(for: vc, title: "No data", message: "") { _ in
                        return [UIAlertAction(title: "Ok", style: .cancel, handler: { _ in completion?(.Ok) }) ]
                    }
                case .urlError:
                    Alert().create(for: vc, title: "urlError", message: "") { _ in
                        return [UIAlertAction(title: "Ok", style: .cancel, handler: { _ in completion?(.Ok) }) ]
                    }
                }
            case .noData:
                Alert().create(for: vc, title: "No results for this request", message: "No data") { _ in
                    return [UIAlertAction(title: "Ok", style: .cancel, handler: { _ in completion?(.Ok) })]
                }
            }
        }
    }
}
