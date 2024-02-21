//
//  SearchViewControllerViewModel.swift
//  Podcasts
//
//  Created by Anton on 23.09.2023.
//

import UIKit


//MARK: - ViewModel
class SearchViewModel: IPerRequest, ITableViewModel, IViewModelDinamicUpdating, INotifyOnChanged {

    struct Arguments {}
    
    func configureDataSourceForView() {
        dataSourceForView = dataSourceAll
    }
    
    private let router: PresenterService
    private let apiService: ApiService
    private let container: IContainer
        
    typealias SectionData = BaseSectionData<Podcast, String>
    
    var insertSectionOnView: ((Section, Int) -> ())     = { _, _ in }
    var insertItemOnView:    ((Row, IndexPath) -> ())   = { _, _ in }
    var removeRowOnView:     ((IndexPath) -> ())        = {    _ in }
    var removeSectionOnView: ((Int) -> ())              = {    _ in }
    var moveSectionOnView:   ((Int, Int) -> ())         = { _, _ in }
    var reloadSection:       ((Int) -> ())              = { _    in }
    
    var dataSourceForView: [SectionData]
    var dataSourceAll: [SectionData] = []
    
    var updatingDelay: TimeInterval { return 0.01 }
    var isUpdating: Bool = false
    private(set) var isLoading: Bool = false
    var lock: NSLock = NSLock()
    
    //MARK: init
    required init(container: IContainer, args: Arguments) {
        self.router = container.resolve()
        self.apiService = container.resolve()
        self.container = container
        self.dataSourceForView = []
    }
    
    func removeAll() {
//        update(by: [])
    }
    
    func getCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func presentDetailVM(forIndexPath indexPath: IndexPath) {
        let podcast = dataSourceForView[indexPath.section].rows[indexPath.row]
        isLoading = true
        changed.raise()
        
        guard let id = podcast.collectionId?.stringValue else { return }
        let url = DynamicLinkManager.podcastEpisodeById(id).url
        apiService.getData(for: url) { [weak self] (result : Result<PodcastData>) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print("")
                //                error.showAlert(vc: self)
            case .success(result: let podcastData) :
                let podcasts = podcastData.podcasts.filter { $0.wrapperType == "podcastEpisode"}
                let args = DetailViewController.Args.init()
                let argsVM = DetailViewController.ViewModel.Arguments(podcast: podcast, podcasts: podcasts)
                let vc: DetailViewController = container.resolve(args: args, argsVM: argsVM)
                router.present(vc, modalPresentationStyle: .custom)
            }
            
            isLoading = false
            changed.raise()
        }
    }
    
    func getPodcasts(with request: String) {
        
        Task { [weak self] in
            guard let self = self else { return }
            let podcastData: PodcastData? = await self.apiService.getData(for: request)
            
            if let podcastData = podcastData {
                guard let podcasts = podcastData.results.allObjects as? [Podcast] else { return }
                let newDataSource = configureSectionData(podcasts: podcasts)
                update(dataSource: newDataSource)          
            }
        }
    }
    
    func getAuthors(with request: String) {
        apiService.getData(for: request) { [weak self] (result: Result<AuthorData>) in
//            switch result {
//            case .success(result: let authorData) :
//                let authors = authorData.results?.allObjects as? [Author]
//                self?.processResults(result: authors) {
//                    authors = $0
//                }
//            case .failure(error: let error) :
//                error.showAlert(vc: self)
//            }
//            self?.activityIndicator.stopAnimating()
//            self?.view.hideActivityIndicator()
        }
    }
}

//MARK: - Private Methods
extension SearchViewModel {
    
    private func configureSectionData(podcasts: [Podcast]) -> [SectionData] {
        return podcasts.sortPodcastsByGenre
    }
    
//    private func processResults<T>(result: [T]?, completion: (([T]) -> Void)? = nil) {
//        if let result = result, !result.isEmpty {
//            completion?(result)
//        } else {
//            self.alert.create(vc: self, title: "Ooops nothing search", withTimeIntervalToDismiss: 2)
//        }
//        self.showEmptyImage()
//        searchCollectionView.reloadData()
//    }

}
