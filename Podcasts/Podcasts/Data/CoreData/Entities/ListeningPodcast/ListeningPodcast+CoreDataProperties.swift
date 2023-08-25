//
//  ListeningPodcast+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 25.08.2023.
//
//

import Foundation
import CoreData


extension ListeningPodcast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListeningPodcast> {
        return NSFetchRequest<ListeningPodcast>(entityName: "ListeningPodcast")
    }

    @NSManaged public var currentTime: Float
    @NSManaged public var duration: Double
    @NSManaged public var id: String
    @NSManaged public var progress: Double
    @NSManaged public var podcast: Podcast

}

extension ListeningPodcast : Identifiable {

}
