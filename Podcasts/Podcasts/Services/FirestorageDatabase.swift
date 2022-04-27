//
//  FirebaseManager.swift
//  Podcasts
//
//  Created by Anton on 22.04.2022.
//

import Foundation
import FirebaseStorage
import FirebaseAuth

class FirestorageDatabase {
    
    let storage = Storage.storage()
    let userID = Auth.auth().currentUser!.uid
    lazy var storageRef = storage.reference()
    lazy var imagesRef = storageRef.child("FavoritsPodcast").child(userID)
    lazy var favPodcast = storageRef.child("FavoritsPodcast").child(userID)
    
    func saveFavoritePodcasts(podcasts: [Podcast]) {
        if let data = try? JSONEncoder().encode(podcasts) {
            favPodcast.putData(data, metadata: nil)
        }
    }
    
    func getFavoritePodcasts(userId: String, completion: @escaping ([Podcast]) -> Void) {
        imagesRef.getData(maxSize: Int64.max) { data, erorr in
            guard erorr == nil,
                  let data = data else { return }
            
            let viewContext = DataStoreManager.shared.viewContext
            let decoder = JSONDecoder(context: viewContext)
            
            if let podcasts = try? decoder.decode([Podcast].self, from: data) {
                DispatchQueue.main.async {
                    DataStoreManager.shared.viewContext.mySave()
                    completion(podcasts)
                }
            }
        }
    }
    
    func createObserve() {
        
    }

    ///-------------------------------------------------------------------------------------
    func getLogo(for userId: String, completion: @escaping (UIImage) -> Void) {
        let storage = storageRef.child("LogoImage").child(userId)
        if let imageView = UIImage(named: "photo.on.rectangle") {
            storage.getData(maxSize: 1024*1024) { data, erorr in
                guard erorr == nil,
                      let data = data else { completion(imageView); return }
                
                if let logo = UIImage(data: data) {
                    completion(logo)
                }
            }
        }
    }
    
    func saveLogo(for userId: String, logo: UIImage) {
        let storage = storageRef.child("LogoImage").child(userId)
        guard let imageData = logo.pngData() else { return }
        storage.putData(imageData, metadata: nil)
    }
}
