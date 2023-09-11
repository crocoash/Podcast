//
//  UserViewModel.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 03.11.2021.
//

import Foundation

class UserViewModel: ISingleton {
    
    typealias Arguments = Void
    
    var userLogin: String? {
        return userDocument.user.userName
    }
    
    var userIsLogin: Bool {
        return userDocument.user.isAuthorization
    }
    
    var userInterfaceStyleIsDark: Bool {
        return userDocument.user.userInterfaceStyleIsDark
    }
    
    private(set) var userDocument: UserModel {
        didSet {
            UserDefaults.standard.setValue(userDocument.json, forKey: String(describing: Self.self))
        }
    }
    
    //MARK: init
    required init(container: IContainer, args: Void) {
        userDocument = UserModel(json: UserDefaults.standard.data(forKey: String(describing: Self.self))) ?? UserModel()
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
