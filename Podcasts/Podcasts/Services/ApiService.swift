//
//  ApiService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 25.10.2021.
//

import Foundation
import UIKit
import CoreData

class ApiService {
    
    static func getData<T: Decodable>(for request: String, completion: @escaping (Result<T>) -> Void) {
        
        guard let url = URL(string: request.encodeUrl) else { fatalError() }
        
        let viewContext = DataStoreManager.shared.viewContext
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            var result: Result<T>
            
            defer {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            guard let data = data, response != nil, error == nil else {
                result = .failure(error: .error(error?.localizedDescription ?? "No Data" ))
                return
            }
            
            do {
                let decoder = JSONDecoder(context: viewContext)
                let value = try decoder.decode(T.self, from: data)
                result = .success(result: value)
                
            } catch let error {
                print(error)
                result = .failure(error: .error(error.localizedDescription.debugDescription))
            }
        }.resume()
    }
}
