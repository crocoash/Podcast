//
//  DetailViewControllerViewModel.swift
//  Podcasts
//
//  Created by Anton on 24.09.2023.
//

import Foundation

class DetailViewControllerViewModel: IPerRequest, INotifyOnChanged {
    
    typealias Arguments = Input
    struct Input {
        var podcast: Podcast
        var podcasts: [Podcast]
    }
    let apiService: ApiService
    var podcast: Podcast

    let container: IContainer
    var podcasts: [Podcast]
    
    lazy var episodeTableViewModel: EpisodeTableView.ViewModel = getViewModelEpisodeTableView()
    var activeSortType: EpisodeTableViewModel.TypeSortOfTableView = .byGenre
    
    //MARK: init
    required init?(container: IContainer, args input: Input) {
        
        self.apiService = container.resolve()
        self.podcast = input.podcast
        self.podcasts = input.podcasts
        self.container = container
        
        episodeTableViewModel.configurePlaylist(withPodcast: podcasts)
    }
    
    var sortMenu: [EpisodeTableViewModel.TypeSortOfTableView] = EpisodeTableViewModel.TypeSortOfTableView.allCases
    
    func setActiveSortType(sortType: EpisodeTableViewModel.TypeSortOfTableView) {
        activeSortType = sortType
        changed.raise(())
    }
}

extension DetailViewControllerViewModel {
    
    private func getViewModelEpisodeTableView() ->  EpisodeTableView.ViewModel {
        let argsForEpisodeTableViewModel = EpisodeTableViewModel.Input.init(podcasts: podcasts, typeOfSort: .byNewest)
        return container.resolve(args: argsForEpisodeTableViewModel)
    }
}

