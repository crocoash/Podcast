//
//  LikedMoment+CoreDataProperties.swift
//  Podcasts
//
//  Created by Anton on 04.05.2022.
//
//

import Foundation
import CoreData

extension LikedMoment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LikedMoment> {
        return NSFetchRequest<LikedMoment>(entityName: Self.entityName)
    }
    
    @NSManaged public var moment: Double
    @NSManaged public var podcast: Podcast

}
extension LikedMoment : Identifiable {
    
    static var likedMomentFRC: NSFetchedResultsController<LikedMoment> = {
        let fetchRequest: NSFetchRequest<LikedMoment> = LikedMoment.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(LikedMoment.moment), ascending: true)]
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
       
        do {
            try fetchResultController.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(error), \(nserror.userInfo)")
        }
        return fetchResultController
    }()
    
    
    static var likedMoments: [LikedMoment] { viewContext.fetchObjects(Self.self) }
    static var isEmpty: Bool { likedMoments.isEmpty }
    static var countOfLikedMoments: Int { likedMomentFRC.sections?.first?.numberOfObjects ?? 0 }
    
    var podcastId: String? { podcast.id?.stringValue }
    var key: String { moment.formattedString + (podcastId ?? "") }
   
    static var addFromFireBase: (LikedMoment) -> Void = {
        LikedMoment.getOrCreateLikedMoment($0)
    }
    
    static var removeFromFireBase: (LikedMoment) -> Void = {
        if let likedMoment = getLikeMoment(likedMoment: $0) {
            deleteFromDevice(likedMoment)
        }
    }
    
    static func delete(_ moment: LikedMoment) {
        let key = moment.key
        deleteFromDevice(moment)
        deleteFromFireBase(moment: moment,key)
    }
    
    private static func deleteFromFireBase(moment: LikedMoment,_ key: String) {
        FirebaseDatabase.shared.remove(object: moment, key: key)
    }
    
    static func deleteFromDevice(_ moment: LikedMoment) {
        let podcast = moment.podcast
        viewContext.delete(moment)
        viewContext.mySave()
        Podcast.remove(podcast)
    }
    
    static func getLikedMoment(at indexPath: IndexPath) -> LikedMoment {
        return likedMomentFRC.object(at: indexPath)
    }
    
    static func getOrCreateLikedMoment(_ likedMoment: LikedMoment) {
        if getLikeMoment(likedMoment: likedMoment) == nil {
            let podcast = likedMoment.podcast
            let moment = likedMoment.moment
            _ = LikedMoment(newPodcast: podcast, moment: moment)
        }
    }
    
    static func removaAllLikedMoments() {
        likedMoments.forEach {
            delete($0)
        }
    }
    
    static func updateLikedMomentsFromFireBase(completion: @escaping () -> Void) {
        FirebaseDatabase.shared.update { (result: Result<[LikedMoment]>) in
            switch result {
                
            case .failure(let error) :
                if error == .noData {
                    likedMoments.forEach {
                        deleteFromDevice($0)
                    }
                }
                
            case .success(let podcasts) :
                self.likedMoments.forEach { likedMoment in
                    if !podcasts.contains(where: { ($0.podcast.id == likedMoment.podcast.id) && ($0.moment == likedMoment.moment) }) {
                        deleteFromDevice(likedMoment)
                    }
                }
                
                podcasts.forEach {
                    self.getOrCreateLikedMoment($0)
                }
            }
            completion()
        }
    }
    
    static func getLikeMoment(likedMoment: LikedMoment) -> LikedMoment? {
        likedMoments.filter { ($0.podcast.id == likedMoment.podcast.id) && ($0.moment == likedMoment.moment) }.first
    }
    
    static func getLikeMoment(id: NSNumber?, moment: Double) -> LikedMoment? {
        return likedMoments.filter { $0.podcast.id == id && $0.moment == moment }.first
    }
    
    static func addLikeMoment(podcast: Podcast, moment: Double) {
        if getLikeMoment(id: podcast.id, moment: moment) == nil {
            let likedMoment = LikedMoment(newPodcast: podcast, moment: moment)
            let key = likedMoment.key
            FirebaseDatabase.shared.add(object: likedMoment, key: key)
        }
    }
    
    static func isDownload(_ podcast: Podcast) -> Bool {
        guard let url = podcast.previewUrl.localPath else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
}
