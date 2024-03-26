//
//  FirebaseManager.swift
//  Podcasts
//
//  Created by Anton on 22.04.2022.
//

import UIKit
import FirebaseStorage
import FirebaseAuth

//MARK: - Input
protocol FirestorageDatabaseInput {
    func saveLogo(logo: UIImage)
    func getLogo(comletion: @escaping (UIImage) -> Void)
}
 
class FirestorageDatabase: ISingleton {
    
    required init(container: IContainer, args: ()) { }
    
    let storage = Storage.storage()
    lazy var userID = Auth.auth().currentUser?.uid
    lazy var storageRef = storage.reference()
   
    func getLogo(comletion: @escaping (UIImage) -> Void) {
        let imageView = UIImage(systemName: "photo")!
        
        if let userID = userID {
            storageRef.child("LogoImage").child(userID).getData(maxSize: Int64.max) { data, erorr in
                guard erorr == nil,
                      let data = data else { comletion(imageView); return }
                
                if let logo = UIImage(data: data) {
                    comletion(logo)
                }
            }
        }
    }
        
    func saveLogo(logo: UIImage) {
        guard let imageData = logo.jpegData(compressionQuality: 0.01),
              let userID = userID else { return }
        
        storageRef.child("LogoImage").child(userID).putData(imageData, metadata: nil)
    }
}
