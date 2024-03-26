//
//  MyError.swift
//  Podcasts
//
//  Created by Anton on 30.01.2023.
//

import UIKit

//MARK: - Result
enum Result<T, ER: ERR> {
    case success(result: T)
    case failure(ER)
}

//MARK: -
protocol ERR {
    associatedtype HandlerType
    func showAlert(vc: UIViewController?, completion: Handler?)
}

extension ERR {
    typealias Handler = ((HandlerType) -> Void)
    
}

enum TEs: String {
    case one
}


enum MyError: ERR {
    
    // for default 
    func showAlert(vc: UIViewController?, completion: Handler?) {}
    typealias HandlerType = Void
    
    enum Types {
        case ApiService
    }
    
    case apiService(ApiService)
    case downloadService(DownloadService)
    case firebaseDatabase(FirebaseDatabase)
    case auth(Auth)
    case podcastManager(PodcastManager)
}

//MARK: - Methods
extension MyError {
    

}
