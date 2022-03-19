//
//  ApiService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 25.10.2021.
//

import Foundation
import UIKit

enum Result<T> {
    case success(result: T)
    case failure(error: Error)
}

class ApiService {
    
    static func getData<T: Decodable>(for string: String, completion: @escaping (T?) -> Void) {
        getData(for: string) { (result: Result<T>) in
            switch result {
            case .success(let result):
                completion(result)
            case .failure(let error):
                print("print mistake \(String(describing: error.localizedDescription))")
                completion(nil)
            }
        }
    }
    
    private static func getData<T: Decodable>(for request: String, completion: @escaping (Result<T>) -> Void) {
        
        guard let url = URL(string: request.encodeUrl), UIApplication.shared.canOpenURL(url) else { fatalError() }
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            var obtain: Result<T>
            
            defer {
                DispatchQueue.main.async {
                    completion(obtain)
                }
            }
            
            guard let data = data, response != nil, error == nil else {
                obtain = .failure(error: error!)
                return
            }
            
            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                obtain = .success(result: model)
            } catch let error {
                obtain = .failure(error: error)
            }
            
        }).resume()
    }
}
