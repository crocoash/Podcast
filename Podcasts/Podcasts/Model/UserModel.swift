//
//  UserModel.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 03.11.2021.
//

import Foundation

struct User: Codable {
    var userName: String = ""
    var isAuthorization: Bool = false
}

struct UserDocument: Codable {
    
    var user = User()
    
    var json: Data? { try? JSONEncoder().encode(self) }

    init() {
        
    }
    init? (json: Data?) {
        guard
            let json = json,
            let userDocument = try? JSONDecoder().decode(UserDocument.self, from: json)
        else {
            return nil
        }
        
        self = userDocument
    }
    
    mutating func changeUserName(newName: String) {
        user.userName = newName
    }
    
    mutating func changeAuthorization(value: Bool) {
        user.isAuthorization = value
    }
}
