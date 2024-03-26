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
    let podcastManager: PodcastManager
   
    var smallPlayerViewModel: SmallPlayerViewModel?
//    var searchViewModel: SearchViewModel?
    
    //MARK: init
    required init?(container: IContainer, args: Arguments) {
        self.router = container.resolve()
        self.player = container.resolve()
        self.apiService = container.resolve()
        self.podcastManager = container.resolve()
        
        self.container = container
    }
    
    func getViewControllers() -> [UIViewController] {
        let listVC = UINavigationController(rootViewController: listVC)
        return [mainVC, listVC, searchVC, settingsVC]
    }
    
    lazy private var mainVC: MainViewController = {
//        let args = SearchViewController.Args.init()
//        let argsVM = SearchViewController.ViewModel.Arguments.init()
        let vc: MainViewController = container.resolve(args: (), argsVM: ())
        return createTabBar(vc, title: "Main", imageName: "magnifyingglass")
    }()
    
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
    
        guard let podcast = player.currentTrack?.track.inputType as? Podcast,
              let id = podcast.collectionId?.intValue else { return }
            
        podcastManager.getPodcastEpisodeByCollectionId(id: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                let vc = router.topViewController
                error.showAlert(vc: vc, completion: nil)
                
            case .success(result: let podcasts):
                let vc = DetailViewController.create(container: container, podcast: podcast, podcasts: podcasts)
                router.present(vc, modalPresentationStyle: .custom)
            }
        }
    }
}
