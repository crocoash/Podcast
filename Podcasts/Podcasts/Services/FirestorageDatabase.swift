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
    lazy var logoImage = storageRef.child("LogoImage").child(userID)
   
    func getLogo(comletion: @escaping (UIImage) -> Void) {
        let imageView = UIImage(systemName: "photo")!
        
        logoImage.getData(maxSize: Int64.max) { data, erorr in
            guard erorr == nil,
                  let data = data else { comletion(imageView); return }
            
            if let logo = UIImage(data: data) {
                comletion(logo)
            }
        }
    }
    
    func saveLogo(logo: UIImage) {
        guard let imageData = logo.jpegData(compressionQuality: 0.01) else { return }
        logoImage.putData(imageData, metadata: nil)
    }
}
//24,888,467 bytes
