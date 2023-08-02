//
//  addToLikeManager.swift
//  Podcasts
//
//  Created by Anton on 22.07.2023.
//

import CoreData

protocol LikeManagerDelegate: AnyObject {
    func likeManager(_ LikeManager: LikeManager, didAdd likedMoment: LikedMoment)
    func likeManager(_ LikeManager: LikeManager, didRemove likedMoment: LikedMoment)

}

protocol InputLikeManager {
    func addToLikedMoments(entity: Any, moment: Double)
    func removeFromLikedMoments(entity: LikedMoment)
}

class LikeManager: InputLikeManager {
    
    weak var delegate: LikeManagerDelegate?
    
    lazy private var viewContext = dataStoreManagerInput.viewContext
    private let dataStoreManagerInput: DataStoreManagerInput
    
    init(dataStoreManagerInput: DataStoreManagerInput) {
        self.dataStoreManagerInput = dataStoreManagerInput
    }
    
    func addToLikedMoments(entity: Any, moment: Double) {
        if let podcast = entity as? Podcast {
            let moment = LikedMoment(podcast: podcast, moment: moment, viewContext: viewContext, dataStoreManagerInput: dataStoreManagerInput)
            delegate?.likeManager(self, didRemove: moment)
        }
    }
    
    func removeFromLikedMoments(entity: LikedMoment) {
        dataStoreManagerInput.removeFromCoreData(entity: entity)
        delegate?.likeManager(self, didRemove: entity)
    }
}
