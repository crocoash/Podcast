//
//  UserModel.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 03.11.2021.
//

import Foundation

// FIXME: Имя файла снова содержит Модел

struct User: Codable {
    // FIXME: должны быть немутабельными
    var userName: String = ""
    var isAuthorization: Bool = false
}

struct UserDocument: Codable {
    
    var user = User()
    
    var json: Data? { try? JSONEncoder().encode(self) }

    init() {
        // FIXME: Зачем пустой инит?
    }

    // FIXME: Вижу, что подобный метод повторяется уже в нескольких местах. Можно попробовать написать какой-то протокол ил идженерик, который будет делать декодирование в зависимости от переданного типа
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
