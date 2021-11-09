//
//  LikedMomentsManager.swift
//  Podcasts
//
//  Created by mac on 08.11.2021.
//

import Foundation

class LikedMomentsManager {
    
    private static var uniqueInstance: LikedMomentsManager?
    
    private init() {}
    
    static func shared() -> LikedMomentsManager {
        if uniqueInstance == nil {
            uniqueInstance = LikedMomentsManager()
        }
        return uniqueInstance!
    }
    
    var likedMoments: [LikedMoment] = [] {
        didSet {
            writeInUserDefaults(LikedMomentsManager.shared().likedMoments)
            print("Hi from didSet")
        }
    }
    
    func saveThis(_ moment: LikedMoment) {
        likedMoments.append(moment)
    }
    
    private func writeInUserDefaults(_ array: [LikedMoment]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(array)
            UserDefaults.standard.setValue(data, forKey: "LikedMoments")
        } catch {
            print("error of encoding")
        }
    }
    
    func getLikedMomentsFromUserDefault() -> [LikedMoment] {
        
        if let data = UserDefaults.standard.data(forKey: "LikedMoments") {
            do {
                let decode = JSONDecoder()
                let moments = try decode.decode([LikedMoment].self, from: data)
                return moments
            } catch {
                print("Error in decoding process")
            }
        }
        let moments: [LikedMoment] = []
        return moments
    }
    
}
