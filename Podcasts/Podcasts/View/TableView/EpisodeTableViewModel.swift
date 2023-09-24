//
//  EpisodeTableViewModel.swift
//  Podcasts
//
//  Created by Anton on 20.09.2023.
//

import Foundation

class EpisodeTableViewModel: IPerRequest, INotifyOnChanged, ITableViewDinamicUpdating, ITableViewSorting {
    
    typealias SectionData = BaseSectionData<Podcast, String>
    
    struct Input {
        var podcasts: [Podcast]
        var typeOfSort: TypeSortOfTableView
    }
    
    typealias Arguments = Input
    
    var dataSourceAll: [SectionData] = []
    var dataSourceForView: [SectionData] { dataSourceAll }
    
    var insertSectionOnView: ((SectionData, Int) -> ()) = { _, _ in }
    var insertItemOnView:    ((Row, IndexPath  ) -> ()) = { _, _ in }
    var removeRowOnView:    ((IndexPath       ) -> ()) = {    _ in }
    var removeSectionOnView: ((Int             ) -> ()) = {    _ in }
    var moveSectionOnView:   ((Int, Int        ) -> ()) = { _, _ in }
    
    let container: IContainer
    private var podcasts: [Podcast]
    
    //MARK: init
    required init?(container: IContainer, args input: Input) {
        self.container = container
        self.podcasts = input.podcasts
        self.typeOfSort = input.typeOfSort
        
        configurePlaylist(withPodcast: podcasts)
    }
    
    enum TypeSortOfTableView: String, CaseIterable {
        case byNewest = "by newest"
        case byOldest = "by oldest"
        case byGenre = "by genres"
    }
    
    var typeOfSort: TypeSortOfTableView {
        didSet {
            configurePlaylist(withPodcast: podcasts)
        }
    }
}

//MARK: - Private Methods
extension EpisodeTableViewModel {
    
    private func configurePlaylist(withPodcast newPodcast: [Podcast]) {
        
        var newPlaylist = dataSourceAll
        
        switch typeOfSort {
        case .byGenre:
            newPlaylist = newPodcast.sortPodcastsByGenre
        case .byNewest:
            newPlaylist = newPodcast.sortPodcastsByNewest
        case .byOldest:
            newPlaylist = newPodcast.sortPodcastsByOldest
        }
        update(by: newPlaylist)
    }
}
