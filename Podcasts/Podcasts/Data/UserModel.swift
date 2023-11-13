//
//  UserDocument.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 10.11.2021.
//

import Foundation

struct UserModel: Codable {
    
    init(userName: String, userId: String) {
        self.user = User(userName: userName, userId: userId)
    }
    
    var user: User
    
    var json: Data? { try? JSONEncoder().encode(self) }

    init? (json: Data?) {
        guard let json = json,
              let userDocument = try? JSONDecoder().decode(UserModel.self, from: json) else { return nil }
        
        self = userDocument
    }
    
    mutating func changeUserName(newName: String) {
        user.userName = newName
    }
    
    mutating func chageUserId(newUserId: String) {
        user.userId = newUserId
    }
    
    mutating func changeAuthorization(value: Bool) {
        user.isAuthorization = value
    }
    
    mutating func changeUserInterfaceStyle(value: Bool) {
        user.userInterfaceStyleIsDark = value
    }
}
