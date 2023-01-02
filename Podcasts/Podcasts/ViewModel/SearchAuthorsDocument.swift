//
//  SearchAuthorsDocument.swift
//  Pods
//
//  Created by Anton on 17.04.2022.
//

import Foundation
import CoreData

class SearchAuthorsDocument {
    
    static var shared = SearchAuthorsDocument()
    private init(){}
    
    lazy private(set) var searchFRC: NSFetchedResultsController<Author> = {
        let fetchRequest: NSFetchRequest<Author> = Author.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Author.artistID), ascending: true)]
        
        fetchRequest.returnsObjectsAsFaults = false
        
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: Author.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try! fetchResultController.performFetch()
        return fetchResultController
    }()
}

extension SearchAuthorsDocument {
    
    private var authors: [Author] { Author.searchAuthors }
    
    var authorsIsEmpty: Bool { authors.isEmpty }
    
    func getAuthor(at indexPath: IndexPath) -> Author {
        return searchFRC.object(at: indexPath)
    }
    
    func indexPath(for object: Author) -> IndexPath? {
        return searchFRC.indexPath(forObject: object)
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return searchFRC.sections?[section].numberOfObjects ?? 0
    }
}
