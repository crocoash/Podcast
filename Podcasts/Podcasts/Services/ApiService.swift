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
                print("print mistake \(String(describing: error))")
                completion(nil)
            }
        }
    }
    
    private static func getData<T: Decodable>(for request: String, completion: @escaping (Result<T>) -> Void) {
        
        guard let url = URL(string: request.encodeUrl) else { fatalError() }
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            var result: Result<T>
        
            defer {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            guard let data = data, response != nil, error == nil else {
                result = .failure(error: error!)
                return
            }
            
            do {
//                if let type = T.self as? SaveContextProtocol.Type {
//                    type.remove()
//                    Author.remove()
//                }
                
                let context = DataStoreManager.shared.viewContext
                let decoder = JSONDecoder(context: context)
                let res = try decoder.decode(T.self, from: data)
//                try? context.save()
                
                result = .success(result: res)
            } catch let error {
                result = .failure(error: error)
            }
        }).resume()
    }
}
