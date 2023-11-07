//
//  EpisodeTableViewModel.swift
//  Podcasts
//
//  Created by Anton on 20.09.2023.
//

import UIKit

class EpisodeTableViewModel: IPerRequest, INotifyOnChanged, ITableViewDinamicUpdating, ITableViewSorting {
   
    
    
    typealias SectionData = BaseSectionData<Podcast, String>
    
    struct Input {
        var podcasts: [Podcast]
        var typeOfSort: TypeSortOfTableView
    }
    
    typealias Arguments = Input
    
    var dataSourceAll: [SectionData] = []
    var dataSourceForView: [SectionData] { dataSourceAll }
    
    var insertSectionOnView: ((Section, Int) -> ()) = { _, _ in }
    var insertItemOnView:    ((Row, IndexPath  ) -> ()) = { _, _ in }
    var removeRowOnView:    ((IndexPath        ) -> ()) = {    _ in }
    var removeSectionOnView: ((Int             ) -> ()) = {    _ in }
    var moveSectionOnView:   ((Int, Int        ) -> ()) = { _, _ in }
    var reloadSection: ((Int) -> ())                    = { _    in }
    
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
    
    //MARK: Public Methods
    @objc func tapCell(sender: MyTapGestureRecognizer) {
        guard let cell = sender.info as? UITableViewCell else { return }
        cell.isSelected.toggle()
    }
    
    func getCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
        let podcast = getRow(forIndexPath: indexPath)
        cell.addMyGestureRecognizer(self, type: .tap(), #selector(tapCell), info: cell)
        
        let podcasts = getRows(atSection: indexPath.section)
        let args = PodcastCellViewModel.Arguments.init(podcast: podcast, playlist: podcasts)
        cell.viewModel = container.resolve(args: args)
        return cell
    }
}

//MARK: - Private Methods
extension EpisodeTableViewModel {
    
    func configurePlaylist(withPodcast newPodcast: [Podcast]) {
        
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
