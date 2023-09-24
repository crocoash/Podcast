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
    
    var podcast: Podcast
    var podcasts: [Podcast]
    
    var viewModelEpisodeTableView: EpisodeTableView.ViewModel
   
    //MARK: init
    required init?(container: IContainer, args input: Input) {
        self.podcast = input.podcast
        self.podcasts = input.podcasts
        let argsForEpisodeTableViewModel = EpisodeTableViewModel.Input.init(podcasts: input.podcasts, typeOfSort: .byNewest)
        self.viewModelEpisodeTableView = container.resolve(args: argsForEpisodeTableViewModel)
    }
    
    lazy var activeSortType = viewModelEpisodeTableView.typeOfSort
    
    var sortMenu: [EpisodeTableViewModel.TypeSortOfTableView] = EpisodeTableViewModel.TypeSortOfTableView.allCases
    
    func setActiveSortType(sortType: EpisodeTableViewModel.TypeSortOfTableView) {
        activeSortType = sortType
        viewModelEpisodeTableView.typeOfSort = sortType
        changed.raise(())
    }
}
