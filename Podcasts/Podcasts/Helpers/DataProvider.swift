//
//  DataProvider.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 07.11.2021.
//

import UIKit

class DataProvider {
    
    var imageCache = NSCache<NSString, UIImage>()
    
    func downloadImage(string: String?, completion: @escaping (UIImage?) -> Void) {
        guard let string = string,
              let url = URL(string: string) else { return }
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
        } else {
            let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 10)
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                
                guard error == nil,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      let data = data else { return }
                
                guard let image = UIImage(data: data) else { return }
                
                self?.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                
                DispatchQueue.main.async {
                    completion(image)
                }
            }.resume()
        }
    }
}
