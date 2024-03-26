//
//  SearchViewControllerViewModel.swift
//  Podcasts
//
//  Created by Anton on 23.09.2023.
//

import UIKit

//MARK: - ViewModel
class SearchViewModel: IPerRequest, ITableViewModel, IViewModelDinamicUpdating, INotifyOnChanged {
    
    typealias Row = Podcast
    typealias Section = String
    typealias SectionData = BaseSectionData<Podcast, String>
    
    struct Arguments {}
    
    func configureDataSourceForView() {
        dataSourceForView = dataSourceAll
    }
    
    /// Servises
    private let router: PresenterService
    private let apiService: ApiService
    private let container: IContainer
    private let podcastManager: PodcastManager
        
    var insertSectionOnView: ((Section, Int) async -> ())   = { _, _ in }
    var insertItemOnView:    ((Row, IndexPath) async -> ()) = { _, _ in }
    var removeRowOnView:     ((IndexPath) async -> ())      = {    _ in }
    var removeSectionOnView: ((Int) async -> ())            = {    _ in }
    var moveSectionOnView:   ((Int, Int) async -> ())       = { _, _ in }
    var reloadSection:       ((Int) async -> ())            = { _    in }


    var dataSourceForView: [SectionData]
    var dataSourceAll: [SectionData] = []
    
    
    var updatingDelay: TimeInterval { return 0.01 }
    var isUpdating: Bool = false { didSet { changed.raise() }}
    private(set) var selectedSegmentIndex = 0
    private(set) var searchText: String = ""
    
    //MARK: init
    required init(container: IContainer, args: Arguments) {
        self.router = container.resolve()
        self.apiService = container.resolve()
        self.podcastManager = container.resolve()
        
        self.container = container
        self.dataSourceForView = []
    }
    
    func setSelectedSegmentIndex(newValue value: Int) {
        selectedSegmentIndex = value
        changed.raise()
        getPodcast()
    }
    
    func removeAll() {
        Task { await self.update(by: [])}
    }
    
    func getCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func setSearchedText(text: String) {
        searchText = text
        changed.raise()
    }
    
    func getPodcast() {
        let text = searchText.conform
        guard !text.isEmpty else { return }
        
        isUpdating = true
        Task {
            switch selectedSegmentIndex {
            case 0:
                await getPodcasts(byName: text)
            case 1:
                await getPodcasts(byAuthorName: text)
            default:
                fatalError()
            }
        }
    }
    
    func presentDetailVM(forIndexPath indexPath: IndexPath) {
        let podcast = dataSourceForView[indexPath.section].rows[indexPath.row]
        isUpdating = true
        
        guard let id = podcast.collectionId?.intValue else { return }
        
        podcastManager.getPodcastEpisodeByCollectionId(id: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let podcastManagerError):
                podcastManagerError.showAlert(vc: router.topViewController, completion: nil)
                
            case .success(result: let podcasts):
                let vc = DetailViewController.create(container: container, podcast: podcast, podcasts: podcasts)
                router.present(vc, modalPresentationStyle: .custom)
            }
           
            isUpdating = false
        }
    }
}

//MARK: - Private Methods
extension SearchViewModel {
    
    private func configureSectionData(podcasts: [Podcast]) async -> [SectionData] {
        return await podcasts.sortPodcastsByGenre
    }
    
    private func getPodcasts(byName name: String) async {
        
          podcastManager.getPodcasts(by: .podcastSearch(name)) { [weak self] results in
              guard let self = self else { return }
              
              switch results {
              case .failure(let netWorkError):
                  netWorkError.showAlert(vc: router.topViewController, completion: nil)
              case .success(result: let podcasts):
//                  Task {
                      let sectionData = await podcasts.sortPodcastsByGenre
                      await self.update(by: sectionData)
//                  }
              }
              //            dataSourceAll
              isUpdating = false
        }
    }
    
    private func getPodcasts(byAuthorName authorName: String) async {
        
        podcastManager.getPodcasts(byAuthorName: authorName) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                error.showAlert(vc: router.topViewController, completion: nil)
                await update(by: [])
              
            case .success(result: let podcastsByAuthor):
                let sectionData = podcastsByAuthor.map { SectionData(section: $0.authorName, rows: $0.podcasts)}
                await update(by: sectionData)
            }
            isUpdating = false
        }
    }
}
