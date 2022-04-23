//
//  FirebaseManager.swift
//  Podcasts
//
//  Created by Anton on 22.04.2022.
//

import Foundation
import FirebaseStorage

class FirebaseManager {
    
    let storage = Storage.storage()
    lazy var storageRef = storage.reference()
    
    func saveFavoritePodcasts(userId: String, podcasts: [Podcast]) {
        let imagesRef = storageRef.child("FavoritsPodcast").child(userId)
        if let data = try? JSONEncoder().encode(podcasts) {
            imagesRef.putData(data, metadata: nil)
        }
    }
    
    func getFavoritePodcasts(userId: String, completion: @escaping ([Podcast]) -> Void) {
    
        ///viewcontext
        
        let imagesRef = storageRef.child("FavoritsPodcast").child(userId)
        imagesRef.getData(maxSize: Int64.max) { data, erorr in
            guard erorr == nil,
                  let data = data else { return }
            
            let viewContext = DataStoreManager.shared.viewContext
            let decoder = JSONDecoder(context: viewContext)
            
            if let podcasts = try? decoder.decode([Podcast].self, from: data) {
                DispatchQueue.main.async {
                    completion(podcasts)
                    viewContext.mySave()
                }
            }
        }
    }
}
