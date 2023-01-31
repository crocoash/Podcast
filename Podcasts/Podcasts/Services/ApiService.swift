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
            
            guard let data = data, response != nil, error == nil else {
                completion(.failure(error: .error(error?.localizedDescription ?? "No Data" )))
                return
            }
            
            do {
                let decoder = JSONDecoder(context: viewContext)
                let value = try decoder.decode(T.self, from: data)
                completion(.success(result: value))
                
            } catch let error {
                completion(.failure(error: .error(error.localizedDescription)))
            }
        }.resume()
    }
}
