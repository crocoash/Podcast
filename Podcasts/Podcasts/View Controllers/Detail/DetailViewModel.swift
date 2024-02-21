//
//  DetailViewControllerViewModel.swift
//  Podcasts
//
//  Created by Anton on 24.09.2023.
//

import UIKit

class DetailViewModel: IPerRequest, INotifyOnChanged {
    
    typealias Arguments = Input
    
    struct Input {
        var podcast: Podcast
        var podcasts: [Podcast]
    }
    
    ///Services
    let apiService: ApiService
    var podcast: Podcast
    let player: Player
    let container: IContainer
    let router: PresenterService
    
    private(set) var searchedIndexPath: IndexPath?
    private(set) var playerIsHidden: Bool
    private(set) var podcasts: [Podcast]
    private(set) var smallPlayerViewModel: SmallPlayerViewModel?
    
    var episodeTableViewModel: EpisodeTableView.ViewModel
    var activeSortType: EpisodeTableViewModel.TypeSortOfTableView { episodeTableViewModel.typeOfSort }
    
    //MARK: init
    required init?(container: IContainer, args input: Input) {
        
        self.apiService = container.resolve()
        self.podcast = input.podcast
        self.podcasts = input.podcasts
        self.container = container
        self.player = container.resolve()
        self.router = container.resolve()
        
        playerIsHidden = player.currentTrack == nil
        
        let argsVM = EpisodeTableViewModel.Arguments.init(podcasts: podcasts, typeOfSort: .byNewest)
        self.episodeTableViewModel = container.resolve(args: argsVM)
        
        if let track = player.currentTrack?.track {
            let argsVM = SmallPlayerViewModel.Arguments(item: track)
            self.smallPlayerViewModel = container.resolve(args: argsVM)
        }
        
        player.delegate = self
    }
    
    var sortMenu: [EpisodeTableViewModel.TypeSortOfTableView] = EpisodeTableViewModel.TypeSortOfTableView.allCases
    
    func changeSortType(sortType: EpisodeTableViewModel.TypeSortOfTableView) {
        episodeTableViewModel.changeTypeOfSort(sortType)
    }
    
    func presentBigPlayer() {
        guard let input = player.currentTrack?.track as? any BigPlayerInputType else { return }
        let argsVM: BigPlayerViewController.ViewModel.Arguments = BigPlayerViewController.ViewModel.Arguments.init(input: input)
        let args: BigPlayerViewController.Arguments = BigPlayerViewController.Arguments.init(delegate: self)
        let bigPlayerViewController: BigPlayerViewController = container.resolve(args: args, argsVM: argsVM)
        router.present(bigPlayerViewController, modalPresentationStyle: .fullScreen)
    }
    
    func presentSmallPlayer()  {
        guard let item = player.currentTrack?.track, playerIsHidden else { return }
        let argsVM = SmallPlayerView.ViewModel.Arguments.init(item: item)
        self.smallPlayerViewModel = container.resolve(args: argsVM)
        
        playerIsHidden = false
        changed.raise()
    }
    
    func openCell(atIndexPath indexPath: IndexPath) {
        
    }
}

//MARK: - BigPlayerViewControllerDelegate
extension DetailViewModel: BigPlayerViewControllerDelegate {
    
    func bigPlayerViewControllerDidTouchPodcastNameLabel(_ bigPlayerViewController: BigPlayerViewController) {
        bigPlayerViewController.dismiss(animated: true, completion: { [weak self] in
            guard let self = self,
                  let podcast = player.currentTrack?.track.inputType as? Podcast,
                  let index = podcasts.firstIndex(where: { podcast == $0 }) else { return }
            searchedIndexPath = IndexPath(row: index, section: 0)
            changed.raise()
        })
    }
}


//MARK: - PlayerDelegate
extension DetailViewModel: PlayerDelegate {
    
    func playerDidEndPlay(_ player: Player, with track: any OutputPlayerProtocol) {}
    
    func playerStartLoading(_ player: Player, with track: any OutputPlayerProtocol) {
        presentSmallPlayer()
    }
    
    func playerDidEndLoading(_ player: Player, with track: any OutputPlayerProtocol) {}
    
    func playerUpdatePlayingInformation(_ player: Player, with track: any OutputPlayerProtocol) {}
    
    func playerStateDidChanged(_ player: Player, with track: any OutputPlayerProtocol) {}
}
