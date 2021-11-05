//
//  UserDocument.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 03.11.2021.
//

import Foundation

// FIXME: Имя файла и имя класса не совпадает

class UserViewModel {
    
    private let key = "UserViewModel"
    
    private(set) var userDocument: UserDocument {
        didSet {
            // FIXME: Логику с юзер дефолтс выносим в отдельный сервис (менеджер)
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
}
