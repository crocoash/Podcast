//
//  UserDocument.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 03.11.2021.
//

import Foundation

class UserViewModel {
    
    private let key = "UserViewModel"
    
    private(set) var userDocument: UserDocument? {
        didSet {
            UserDefaults.standard.setValue(userDocument?.json, forKey: key)
            print("print UserDocument UserDefaults)")
        }
    }
    
    init(user: UserDocument) {
        self.userDocument = user
    }
    
    init?() {
        userDocument = UserDocument(json: UserDefaults.standard.data(forKey: key))
        
        if userDocument == nil {
            print("print UserDocument nil)")
        } else {
            print("print UserDocument not nil)")
        }
    }
}
