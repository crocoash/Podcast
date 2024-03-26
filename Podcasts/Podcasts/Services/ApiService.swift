//
//  ApiService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 25.10.2021.
//

import Foundation
import UIKit
import CoreData

class ApiService: ISingleton {
    
    required init(container: IContainer, args: ()) {
        let dataStoreManager: DataStoreManager = container.resolve()
        self.viewContext = dataStoreManager.viewContext
    }
    
    typealias Output<T> = (Result<T, MyError.ApiService>)
    typealias Clouser<T> = @MainActor (Result<T, MyError.ApiService>) -> Void
    
    private var viewContext: NSManagedObjectContext
}


extension ApiService {
    
    func getData<T: Decodable>(_ decodeType: T.Type, for request: String) async -> Output<T> {
        
        guard let url = URL(string: request.encodeUrl) else { return .failure(.urlError) }
        do {
            let response = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder(context: viewContext)
            let value = try decoder.decode(T.self, from: response.0)
            return .success(result: value)
            
        } catch let error {
            return .failure(.error(error))
        }
    }
    
    func getData<T: Decodable>(_ decodeType: T.Type, for request: String, completion: @escaping Clouser<T>) {
        
        guard let url = URL(string: request.encodeUrl) else { fatalError() }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let self = self else { return }
            
            var result: Result<T,MyError.ApiService>

            defer {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            if let error = error {
                result = .failure(.error(error))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    result = .failure(.responseError)
                }
            }
            
            guard let data = data else {
                result = .failure(.noData)
                return
            }
            
            do {
                let decoder = JSONDecoder(context: viewContext)
                let value = try decoder.decode(T.self, from: data)
                result = .success(result: value)
                
            } catch let error {
                result = .failure(.error(error))
            }
        }.resume()
    }
}
