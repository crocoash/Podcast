//
//  ApiService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 25.10.2021.
//

import Foundation
import UIKit
import CoreData

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
        
        let viewContext = DataStoreManager.shared.viewContext
        
        
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            var result: Result<T>
            defer {
                DispatchQueue.main.async {
                    viewContext.mySave()
                    completion(result)
                }
            }
            guard let data = data, response != nil, error == nil else {
                result = .failure(error: error!)
                return
            }
            do {
                let decoder = JSONDecoder(context: viewContext)
                let data = try decoder.decode(T.self, from: data)
                result = .success(result: data)
                
            } catch let error {
                result = .failure(error: error)
            }
        }.resume()
    }
}
