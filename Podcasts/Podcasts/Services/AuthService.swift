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
    
    required init(container: IContainer, args: ()) {
       
    }
    
    func signInWithEmail (user email: String, password: String, completion: @escaping (Result<User>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
            
            if let err = err?.localizedDescription {
                let alertData: MyError.AlertData = (title: err, message: "", actions: nil)
                completion(.failure(.auth(.error(alertData))))
                return
            }
            guard let userId = Auth.auth().currentUser?.uid else { return }
            let user = User(userName: email, userId: userId)
            completion(.success(result: user))
        }
    }
    
    func signUpWithEmail (email: String, password: String, completion: @escaping (Result<User>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            
            if let err = err?.localizedDescription {
                if err.contains("email") {
                    let alertData: MyError.AlertData = (title: err, message: "", actions: nil)
                    completion(.failure(.auth(.errorEmail(alertData))))
                } else if  err.contains("password") {
                    let alertData: MyError.AlertData = (title: "", message: "", actions: nil)
                    completion(.failure(.auth(.errorEmail(alertData))))
                } else {
                    completion(.failure(MyError.auth(.error((title: err, message: "", actions: nil)))))
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
