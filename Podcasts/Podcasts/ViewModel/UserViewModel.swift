//
//  UserViewModel.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 03.11.2021.
//

import Foundation

class UserViewModel {
    
    private let key = "UserViewModel"
    
    private(set) var userDocument: UserDocument {
        didSet {
            UserDefaults.standard.setValue(userDocument.json, forKey: key)
        }
    }
    
    init() {
       userDocument =  UserDocument(json: UserDefaults.standard.data(forKey: key)) ?? UserDocument()
    }
    
    func changeUserName(newName: String) {
        if userDocument.user.userName != newName {
            userDocument.changeUserName(newName: newName)
        }
    }
    
    func changeAuthorization(value: Bool) {
        userDocument.changeAuthorization(value: value)
    }
    
    func changeUserInterfaceStyle(value: Bool) {
        userDocument.changeUserInterfaceStyle(value: value)
    }
}
