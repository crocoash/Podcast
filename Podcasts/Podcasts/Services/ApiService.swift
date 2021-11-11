//
//  ApiService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 25.10.2021.
//

import Foundation

class ApiService {
    
    static func getData<T: Decodable>(for request: String, completion: @escaping (T?) -> Void) {
        
        guard let url = URL(string: request.encodeUrl) else { completion(nil); return }
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data, response != nil, error == nil else { print(error!.localizedDescription)
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
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
