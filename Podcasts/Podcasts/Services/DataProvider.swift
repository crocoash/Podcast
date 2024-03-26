//
//  DataProvider.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 07.11.2021.
//

import UIKit

class DataProvider {
    
    static var shared = DataProvider()
    private init() {}
    
    var imageCache = NSCache<NSString, UIImage>()
    
    private var activeDownloads: [String: URLSessionDataTask] = [:]
    
    func cancelDownload(string: String) {
        if let dataTask = activeDownloads[string] {
            dataTask.cancel()
            activeDownloads[string] = nil
        }
    }
    
    func downloadImage(string: String?, completion: @escaping (UIImage?) -> Void) {
        
        guard let string = string,
              let url = URL(string: string) else { return }
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
        } else {
            
            let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 100)
            
            activeDownloads[string] = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                guard error == nil,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      let data = data,
                      let image = UIImage(data: data) else { return }
                
                imageCache.setObject(image, forKey: url.absoluteString as NSString)
               
                DispatchQueue.main.async {
                    self.activeDownloads[string] = nil
                    completion(image)
                }
            }
            activeDownloads[string]?.resume()
        }
    }
}

extension String {
    var getImage: UIImage? {
        var image: UIImage?
         DataProvider.shared.downloadImage(string: self) {
            image = $0
        }
        return image
    }
}
