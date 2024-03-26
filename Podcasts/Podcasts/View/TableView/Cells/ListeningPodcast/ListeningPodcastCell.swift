//
//  TableViewCell.swift
//  Podcasts
//
//  Created by Anton on 22.07.2023.
//

import UIKit

//MARK: - Input protocol
protocol ListeningPodcastCellProtocol {
    var id: String { get }
    var duration: Double? { get }
    var listeningProgress: Double? { get }
    var imageForCell: String? { get }
    var podcastName: String? { get }
}

//MARK: - PlayableProtocol
protocol ListeningPodcastCellPlayableProtocol: Identifiable {
    var id: String { get }
    var listeningProgress: Double? { get }
    var duration: Double? { get }
}

class ListeningPodcastCellModel: IPerRequest, IViewModelUpdating, INotifyOnChanged, ListeningPodcastCellPlayableProtocol {
    
    typealias Arguments = ListeningPodcast
    
    ///Servicies
    let listeningManager: ListeningManager
    
    var id: String
    var listeningProgress: Double?
    var duration: Double?
    var podcastName: String?
    var image: String?

    required init?(container: IContainer, args input: ListeningPodcast) {
        
        self.image = input.podcast.image600
        self.podcastName = input.podcast.trackName
        self.duration = input.duration
        self.listeningProgress = input.progress
        self.id = input.id
        
        self.listeningManager = container.resolve()
        
        listeningManager.delegate = self
    }
    
    func update(with input: Any) {
        if let listeningPodcast = input as? ListeningPodcast {
            
            if listeningPodcast.id == id {
                listeningProgress = listeningPodcast.progress
                duration = listeningPodcast.duration
                changed.raise()
            }
        }
    }
}

extension ListeningPodcastCellModel: ListeningManagerDelegate {}


class ListeningPodcastCell: UITableViewCell, IHaveViewModel {
   
    func configureUI() { }
    
    typealias ViewModel = ListeningPodcastCellModel
    
    func viewModelChanged() {
        updateUI()
    }
    func viewModelChanged(_ viewModel: ListeningPodcastCellModel) {}
    
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var listeningImageView: UIImageView!

}

//MARK: - Private Methods
extension ListeningPodcastCell {
    
    func updateUI() {
        progressView.progress = Float(viewModel.listeningProgress ?? 0)
        name.text = viewModel.podcastName
        DataProvider.shared.downloadImage(string: viewModel.image) {
            self.listeningImageView.image = $0
        }
    }
}
