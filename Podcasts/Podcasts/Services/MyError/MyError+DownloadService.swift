//
//  DownloadService.swift
//  Podcasts
//
//  Created by Anton on 19.03.2024.
//

import UIKit

//MARK: DownloadService
extension MyError {
    
    enum DownloadService: ERR {
        
        case noInternetConnection
        case internetTypeCellular(String)
        case cannotRemove(NSError)
        
        enum HandlerType {
            case Ok
            case No
            case Yes
        }
        
        func showAlert(vc: UIViewController?, completion: Handler?) {
            
            guard let vc = vc else { return }
            
            switch self {
            case .noInternetConnection:
                
                Alert().create(for: vc, title: "Download error", message: "No Internet") { _ in
                    [UIAlertAction(title: "Ok", style: .cancel, handler: { _ in completion?(.Ok) })]
                }
            case .internetTypeCellular(let error):
                Alert().create(for: vc, title: "Download error", message: error) { _ in
                    [
                        UIAlertAction(title: "No", style: .cancel, handler: { _ in completion?(.No) }),
                        UIAlertAction(title: "Yes", style: .default, handler: { _ in completion?(.Yes) }),
                    ]
                }
            case .cannotRemove(let error):
                Alert().create(for: vc, title: "Download error", message: error.localizedDescription) { _ in
                    [ 
                        UIAlertAction(title: "No", style: .cancel, handler: { _ in completion?(.No) }),
                        UIAlertAction(title: "Yes", style: .default, handler: { _ in completion?(.Yes) })
                    ]
                }
            }
        }
    }
}
