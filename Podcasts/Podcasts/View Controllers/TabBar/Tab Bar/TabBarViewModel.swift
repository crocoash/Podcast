//
//  TabBarViewModel.swift
//  Podcasts
//
//  Created by Anton on 21.11.2023.
//

import UIKit

class TabBarViewModel: IPerRequest, INotifyOnChanged {
    
    struct Arguments {}
    
    ///Servises
    let router: PresenterService
    let container: IContainer
    let player: Player
    let apiService: ApiService
   
    var smallPlayerViewModel: SmallPlayerViewModel?
//    var searchViewModel: SearchViewModel?
    
    //MARK: init
    required init?(container: IContainer, args: Arguments) {
        self.router = container.resolve()
        self.player = container.resolve()
        self.apiService = container.resolve()
        
        self.container = container
    }
    
    func getViewControllers() -> [UIViewController] {
        let navigationController = UINavigationController(rootViewController: listVC)
        return [navigationController, searchVC, settingsVC]
    }
    
    lazy private var listVC: ListViewController = {
        let args = ListViewController.Args.init()
        let argsVM = ListViewModel.Arguments.init()
        let vc: ListViewController = container.resolve(args: args, argsVM: argsVM)
        return createTabBar(vc, title: "Playlist", imageName: "folder.fill")
    }()
    
    lazy private var searchVC: SearchViewController = {
        let args = SearchViewController.Args.init()
        let argsVM = SearchViewController.ViewModel.Arguments.init()
        let vc: SearchViewController = container.resolve(args: args, argsVM: argsVM)
        return createTabBar(vc, title: "Search", imageName: "magnifyingglass")
    }()
    
    lazy private var settingsVC: SettingsTableViewController = {
        let args = SettingsTableViewController.Args.init()
        let vc: SettingsTableViewController = container.resolve(args: args)
        return createTabBar(vc, title: "Settings", imageName: "gear")
    }()
}

//MARK: - Private Methods
extension TabBarViewModel {
   
    private func createTabBar<T: UIViewController>(_ vc: T, title: String, imageName: String) -> T {
        vc.tabBarItem.title = title
        vc.tabBarItem.image = UIImage(systemName: imageName)
        return vc
    }
    
    private func presentBigPlayer()  {
        guard let track = player.currentTrack?.track as? BigPlayerInputType else { return }
        let argsVM = BigPlayerViewController.ViewModel.Arguments.init(input: track)
        let args = BigPlayerViewController.Arguments.init(delegate: self)
        let bigPlayerViewController: BigPlayerViewController = container.resolve(args: args, argsVM: argsVM)
        
        router.present(bigPlayerViewController, modalPresentationStyle: .fullScreen)
    }
    
    func getSmallPlayer<T: SmallPlayerInputType>(item: T) -> SmallPlayerView {
        
        let argsVM = SmallPlayerView.ViewModel.Arguments.init(item: item)
        let args = SmallPlayerView.Arguments.init(delegate: self, argsVM: argsVM)
        let smallPlayerVC: SmallPlayerView = container.resolve(args: args, argsVM: argsVM)
        
        listVC.updateConstraintForTableView(playerIsPresent: true)
        searchVC.updateConstraintForTableView(playerIsPresent: true)
        return smallPlayerVC
    }
}

//MARK: - SmallPlayerViewDelegate
extension TabBarViewModel: SmallPlayerViewDelegate {
    
    func smallPlayerViewControllerSwipeOrTouch(_ smallPlayerView: SmallPlayerView) {
        presentBigPlayer()
    }
}

//MARK: - BigPlayerViewControllerDelegate
extension TabBarViewModel: BigPlayerViewControllerDelegate {
    
    func bigPlayerViewControllerDidTouchPodcastNameLabel(_ bigPlayerViewController: BigPlayerViewController) {
        guard let podcast = player.currentTrack?.track.inputType as? Podcast else { return }
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
        }
    }
}
