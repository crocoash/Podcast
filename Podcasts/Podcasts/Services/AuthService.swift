//
//  AuthManger.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 07.11.2021.
//

import Foundation
import FirebaseAuth

class AuthService {
    
    func signInWithEmail (email: String, password: String, completion: @escaping (Bool, String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
            
            if err != nil {
                completion(false, (err!.localizedDescription))
                return
            }
            
            completion(true, (result?.user.email)!)
        }
    }
    
    func signUpWithEmail (email: String, password: String, completion: @escaping (Bool, String) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            
            if err != nil {
                completion (false, (err!.localizedDescription))
                return
            }
            
            completion(true, (result?.user.email)!)
        }
    }
    
    func forgotPassword(with email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            
            completion(error)
        }
    }
}
