//
//  EpisodeTableViewModel.swift
//  Podcasts
//
//  Created by Anton on 20.09.2023.
//

import UIKit

class EpisodeTableViewModel: IPerRequest, INotifyOnChanged, IViewModelDinamicUpdating, ITableViewSorting {

    var updatingDelay: TimeInterval { return 0.1 }
    var isUpdating: Bool = false
    var lock: NSLock = NSLock()
    
    typealias SectionData = BaseSectionData<Podcast, String>
    
    struct Arguments {
        var podcasts: [Podcast]
        var typeOfSort: TypeSortOfTableView
    }
    
    var dataSourceAll: [SectionData] = []
    var dataSourceForView: [SectionData] = []
    
    var insertSectionOnView: ((Section  , Int      ) -> ()) = { _, _ in }
    var insertItemOnView:    ((Row      , IndexPath) -> ()) = { _, _ in }
    var removeRowOnView:     ((IndexPath           ) -> ()) = {    _ in }
    var removeSectionOnView: ((Int                 ) -> ()) = {    _ in }
    var moveSectionOnView:   ((Int      , Int      ) -> ()) = { _, _ in }
    var reloadSection:       ((Int                 ) -> ()) = { _    in }
    
    let container: IContainer
    private var podcasts: [Podcast]
        
    //MARK: init
    required init?(container: IContainer, args input: Arguments) {
        
        self.container = container
        self.podcasts = input.podcasts
        self.typeOfSort = input.typeOfSort
        
        configurePlaylist(withPodcast: podcasts)
    }
        
    func configureDataSourceForView() {
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
        guard let info = sender.info as? (tableView: EpisodeTableView, indexPath: IndexPath) else { return }
        info.tableView.selectRowAt(indexPath: info.indexPath)
    }
    
    func getCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
        let podcast = getRowForView(forIndexPath: indexPath)
        cell.addMyGestureRecognizer(self, type: .tap(), #selector(tapCell), info: (tableView: tableView, indexPath: indexPath))
        
        let podcasts = getRowsForView(atSection: indexPath.section)
        let args = PodcastCellViewModel.Arguments.init(podcast: podcast, playlist: podcasts)
        cell.viewModel = container.resolve(args: args)
        return cell
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
