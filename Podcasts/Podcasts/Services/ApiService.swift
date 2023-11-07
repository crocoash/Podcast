//
//  ApiService.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 25.10.2021.
//

import Foundation
import UIKit
import CoreData

//MARK: - Input
protocol ApiServiceInput {
    func getData<T: Decodable>(for request: String, completion: @escaping (Result<T>) -> Void)
}

class ApiService: ISingleton {
    
    required init(container: IContainer, args: ()) {
        let dataStoreManager: DataStoreManager = container.resolve()
        self.viewContext = dataStoreManager.viewContext
    }
    
    private var viewContext: NSManagedObjectContext

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
                let alertData: MyError.AlertData = (title: error.localizedDescription, message: "", actions: nil)
                result = .failure(.apiService(.error(alertData)))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    let alertData: MyError.AlertData = (title: "\(response.statusCode)", message: "", actions: nil)
                    result = .failure(.apiService(.error(alertData)))
                }
            }
            
            guard let data = data else {
                let alertData: MyError.AlertData = (title: "NoData", message: "", actions: nil)
                result = .failure(.apiService(.noData(alertData)))
                return
            }
            
            do {
                let decoder = JSONDecoder(context: viewContext)
                let value = try decoder.decode(T.self, from: data)
                result = .success(result: value)
                
            } catch let error {
                print(error)
                let alertData: MyError.AlertData = (title: error.localizedDescription.debugDescription, message: "", actions: nil)
                result = .failure(.apiService(.error(alertData)))
            }
        }.resume()
    }
}
