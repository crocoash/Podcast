//
//  SearchDocument.swift
//  Podcasts
//
//  Created by Anton on 17.04.2022.
//

import Foundation
import CoreData

class SearchPodcastDocument {
    
    static var shared = SearchPodcastDocument()
    private init(){}
    
    private let viewContext = DataStoreManager.shared.viewContext
    var podcasts: [Podcast] { searchResController.fetchedObjects ?? [] }
    
    lazy private(set) var searchResController: NSFetchedResultsController<Podcast> = {
        let fetchRequest: NSFetchRequest<Podcast> = Podcast.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Podcast.trackName), ascending: true)]
        
        fetchRequest.predicate = NSPredicate(format: "isSearched = true")
        
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try! fetchResultController.performFetch()
        return fetchResultController
    }()
}

extension SearchPodcastDocument {
    
    var podcastsIsEmpty: Bool { podcasts.isEmpty }
    
    func getPodcast(at indexPath: IndexPath) -> Podcast {
        return searchResController.object(at: indexPath)
    }
    
    func indexPath(for object: Podcast) -> IndexPath? {
        return searchResController.indexPath(forObject: object)
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return searchResController.sections?[section].numberOfObjects ?? 0
    }
}
