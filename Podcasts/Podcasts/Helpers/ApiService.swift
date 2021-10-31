//
//  ApiService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 25.10.2021.
//

import Foundation

class ApiService {
    
    private static var uniqueInstance: ApiService?
    private init() {}
    
    static var shared: ApiService {
        uniqueInstance ?? ApiService()
    }
    
    func getData<T: Decodable>(for request: String, completion: @escaping (T?) -> Void) {
        
        guard let url = URL(string: request) else { print("invalid url"); return }
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data, response != nil, error == nil else { print(error!.localizedDescription); return }
            
            do {
                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let model = try decoder.decode(T?.self, from: data)
                
                DispatchQueue.main.async {
                    completion(model)
                }
                
            } catch let error {
                print("print \(error)")
            }
            
        }).resume()
    }
}
