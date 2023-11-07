//
//  UserViewModel.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 03.11.2021.
//

import Foundation
import FirebaseAuth

class UserViewModel: ISingleton {
    
    typealias Arguments = Void
    
    var userLogin: String? {
        return userDocument.user.userName
    }
    
    var userIsLogin: Bool {
        return userDocument.user.isAuthorization && userDocument.user.userId != ""
    }
    
    private(set) var userDocument: UserModel {
        didSet {
            UserDefaults.standard.setValue(userDocument.json, forKey: String(describing: Self.self))
        }
    }
    
    //MARK: init
    required init(container: IContainer, args: Void) {
        self.userDocument  = UserModel(json: UserDefaults.standard.data(forKey: String(describing: Self.self))) ?? UserModel(userName: "", userId: "")
    }
    
    func changeUserName(newName: String) {
        if userDocument.user.userName != newName {
            userDocument.changeUserName(newName: newName)
        }
    }
    
    func changeUserId(newUserId: String) {
        if userDocument.user.userId != newUserId {
            userDocument.chageUserId(newUserId: newUserId)
        }
    }
    
    func changeUserName(userId: String) {
        if userDocument.user.userId != userId {
            userDocument.chageUserId(newUserId: userId)
        }
    }
    
    func changeAuthorization(value: Bool) {
        userDocument.changeAuthorization(value: value)
    }
    
    func changeUserInterfaceStyle(value: Bool) {
        userDocument.changeUserInterfaceStyle(value: value)
    }
}
