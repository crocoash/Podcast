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
    
    func getData<T: Codable>(for string: String, completion: @escaping (T?) -> ()) {
        getData(for: string) { (result: Result<T?,Error>) in
            switch result {
            case .success(let result): completion(result)
            case .failure(let error): print("print Error processing json data: \(error)")
            }
        }
    }
    
    private func getData<T: Decodable>(for request: String, completion: @escaping (Result<T?,Error>) -> Void) {
        
        let stringUrl = "https://itunes.apple.com/search?term=\(request)&entity=podcastEpisode"
        
        guard let url = URL(string: stringUrl) else { print("invalid url"); return }
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data, response != nil, error == nil else { completion(.failure(error!)); return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let model = try decoder.decode(T?.self, from: data)
                
                DispatchQueue.main.async {
                    completion(.success(model))
                }
                
            } catch let error {
                print("print \(error)")
            }
            
        }).resume()
    }
}
