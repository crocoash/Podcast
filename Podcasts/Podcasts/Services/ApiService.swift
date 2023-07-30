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
   
    private var viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func getData<T: Decodable>(for request: String, completion: @escaping (Result<T>) -> Void) {
        
        guard let url = URL(string: request.encodeUrl) else { fatalError() }
                
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let self = self else { return }
            
            var result: Result<T>

            defer {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            if let error = error {
                result = .failure(.apiService(.error(error.localizedDescription)))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    result = .failure(.apiService(.error("\(response.statusCode)")))
                }
            }
            
            guard let data = data else {
                result = .failure(.apiService(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder(context: viewContext)
                let value = try decoder.decode(T.self, from: data)
                result = .success(result: value)
                
            } catch let error {
                print(error)
                result = .failure(.apiService(.error(error.localizedDescription.debugDescription)))
            }
        }.resume()
    }
}
