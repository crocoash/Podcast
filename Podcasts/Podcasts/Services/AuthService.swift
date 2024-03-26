//
//  AuthManger.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 07.11.2021.
//

import Foundation
import FirebaseAuth

//MARK: - Input

class AuthService: ISingleton {
    
    required init(container: IContainer, args: ()) {}
    
    func signInWithEmail (user email: String, password: String, completion: @escaping (Result<User, MyError.Auth>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
            
            if let err = err {
                completion(.failure(.error(err)))
                return
            }
            guard let userId = Auth.auth().currentUser?.uid else { return }
            let user = User(userName: email, userId: userId)
            completion(.success(result: user))
        }
    }
    
    func signUpWithEmail (email: String, password: String, completion: @escaping (Result<User, MyError.Auth>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            
            if let err = err {
                let discrpError = err.localizedDescription
                
                if discrpError.contains("email") {
                    completion(.failure(.errorEmail(err)))
                } else if discrpError.contains("password") {
                    completion(.failure(.errorEmail(err)))
                } else {
                    completion(.failure(.error(err)))
                }
                return
            }
            
            guard let result = result, let email = result.user.email else { return }
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            let user = User(userName: email, userId: userId)
            completion(.success(result: user))
        }
    }
    
    func forgotPassword(with email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
}
