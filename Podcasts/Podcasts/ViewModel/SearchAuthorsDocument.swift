//
//  SearchAuthorsDocument.swift
//  Pods
//
//  Created by Anton on 17.04.2022.
//

import Foundation
import CoreData

class SearchAuthorsDocument {
    
    private let viewContext = DataStoreManager.shared.viewContext
    private var authors: [Author] { Author.searchAuthors }
    
    lazy private(set) var searchResController: NSFetchedResultsController<Author> = {
        let fetchRequest: NSFetchRequest<Author> = Author.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Author.artistID), ascending: true)]
        
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

extension SearchAuthorsDocument {
    
    var authorsIsEmpty: Bool { authors.isEmpty }
    
    func getAuthor(at indexPath: IndexPath) -> Author {
        return searchResController.object(at: indexPath)
    }
    
    func indexPath(for object: Author) -> IndexPath? {
        return searchResController.indexPath(forObject: object)
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return searchResController.sections?[section].numberOfObjects ?? 0
    }
}
