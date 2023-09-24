//
//  SearchViewControllerViewModel.swift
//  Podcasts
//
//  Created by Anton on 23.09.2023.
//

import Foundation


//MARK: - ViewModel
class SearchViewControllerViewModel: IPerRequest, ITableViewModel, ITableViewDinamicUpdating {
   
    typealias Section = Podcast
    typealias Arguments = [Podcast]
    typealias SectionData = BaseSectionData<Podcast, String>
    
    var insertSectionOnView: ((SectionData, Int) -> ()) = { _, _ in }
    var insertItemOnView:    ((Row, IndexPath) -> ())   = { _, _ in }
    var removeRowOnView:    ((IndexPath) -> ())        = {    _ in }
    var removeSectionOnView: ((Int) -> ())              = {    _ in }
    var moveSectionOnView:   ((Int, Int) -> ())         = { _, _ in }
    
    var dataSourceForView: [SectionData] { return dataSourceAll }
    var dataSourceAll: [SectionData] = []
    
    required init(container: IContainer, args podcasts: [Podcast]) {
        self.dataSourceAll = configureSectionData(podcasts: podcasts)
    }
    
    func removeAll() {
        update(by: [])
    }
}

//MARK: - Private Methods
extension SearchViewControllerViewModel {
    
    private func configureSectionData(podcasts: [Podcast]) -> [SectionData] {
        return podcasts.sortPodcastsByGenre
    }
}
