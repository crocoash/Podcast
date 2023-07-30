//
//  addToLikeManager.swift
//  Podcasts
//
//  Created by Anton on 22.07.2023.
//

import CoreData

class AddToLikeManager {
      
    lazy private var viewContext = dataStoreManagerInput.viewContext
    private let dataStoreManagerInput: DataStoreManagerInput
    
    init(dataStoreManagerInput: DataStoreManagerInput) {
        self.dataStoreManagerInput = dataStoreManagerInput
    }
    
    func addToLikedMoments(entity: Any, moment: Double) {
        if let podcast = entity as? Podcast {
            LikedMoment(podcast: podcast, moment: moment, viewContext: viewContext, dataStoreManagerInput: dataStoreManagerInput)
        }
    }
}
