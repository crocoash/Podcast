

import UIKit
import CoreData

class TabBarViewController: UITabBarController {
  
    private var downloadService = DownloadService()
    
    // MARK: - variables
    private var trailConstraint: NSLayoutConstraint?
    private var leadConstraint: NSLayoutConstraint?
    
    lazy private var player: Player = Player()
    
    private var imageView: UIImageView =  {
        $0.image = UIImage(named: "decree")
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView())
    
    lazy private var smallPlayer: SmallPlayerView = {
        $0.delegate = self
        $0.isHidden = true
        view.addSubview($0)
        $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
        $0.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        $0.bottomAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        return $0
    }(SmallPlayerView())
    
    private var userViewModel: UserViewModel!
    private let firestorageDatabase = FirestorageDatabase()
    
    lazy private var favoritePodcastVC = createTabBar(FavoritePodcastTableViewController.self , title: "Playlist", imageName: "folder.fill") {
        $0.delegate = self
    }
    
    lazy private var searchVC = createTabBar(SearchViewController.self, title: "Search", imageName: "magnifyingglass") {
        $0.delegate = self
    }
    
    lazy private var settingsVC = createTabBar(SettingsTableViewController.self, title: "Settings", imageName: "gear") { [weak self] vc in
        guard let self = self else { return }
        vc.setUser((self.userViewModel))
        vc.delegate = self
    }
    
    lazy private var detailViewController: DetailViewController = {
        $0.delegate = self
        $0.transitioningDelegate = self
        $0.modalPresentationStyle = .custom
        return $0
    }(DetailViewController.loadFromStoryboard)
    
    lazy private var bigPlayerVc: BigPlayerViewController = {
        $0.delegate = self
        $0.modalPresentationStyle = .fullScreen
        return $0
    }(BigPlayerViewController.loadFromXib)
    
    //MARK: - Public Method
    func setUserViewModel(_ userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
    }
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        fireBase()
        downloadService.delegate = self
    }
}

//MARK: - Private methods
extension TabBarViewController {
    
    private func addOrRemoveFavoritePodcast(vc: UIViewController, podcast: Podcast) {
        if let favoritePodcast = podcast.getFavoritePodcast {
            favoritePodcast.removeFromCoreData()
            downloadService.cancelDownload(podcast)
        } else {
            FavoritePodcast(podcast: podcast)
        }
        feedbackGenerator()
    }
    
    private func downloadOrRemovePodcast(vc: UIViewController, entity: DownloadProtocol) {
        downloadService.conform(vc: vc, entity: entity)
    }
    
    private func startPlay(track: InputPlayerProtocol, playlist: [InputPlayerProtocol]) {
        player.startPlay(track: track, playList: playlist)
        playerIsPresent(true)
    }
    
    private func playerIsPresent(_ value: Bool) {
        smallPlayer.isHidden = !value
        favoritePodcastVC.updateConstraintForTableView(playerIsPresent: value)
        searchVC.updateConstraintForTableView(playerIsPresent: value)
        detailViewController.updateConstraintForTableView(playerIsPresent: value)
    }
    
    private func presentDetailViewController(podcast: Podcast, completion: (() -> Void)? = nil) {
        
        /// don't present new detail vc if it already present ( big player vc )
        guard presentedViewController as? DetailViewController == nil else {
            completion?()
            return
        }
        
        if detailViewController.podcast == podcast {
            self.present(self.detailViewController, animated: true, completion: completion)
        } else {
            guard let id = podcast.collectionId?.stringValue else { return }
            self.view.showActivityIndicator()
            
            ApiService.getData(for: DynamicLinkManager.podcastById(id).url) { [weak self] (result : Result<PodcastData>) in
                guard let self = self else { return }
                self.view.hideActivityIndicator()
                switch result {
                case .failure(let error):
                    error.showAlert(vc: self)
                case .success(result: let podcastData) :
                    let podcasts = podcastData.podcasts.filter { $0.wrapperType == "podcastEpisode"}
                    self.detailViewController.setUp(podcast: podcast, playlist: podcasts)
                    self.present(self.detailViewController, animated: true, completion: completion)
                }
            }
        }
    }
    
    private func presentBigPlayer(for vc: UIViewController) {
        vc.present(bigPlayerVc, animated: true)
        self.bigPlayerVc.setUpUI(with: player)
    }
    
    //MARK: configureView
    private func configureTabBar() {
        let navigationController = UINavigationController(rootViewController: favoritePodcastVC)
        self.viewControllers = [navigationController, searchVC, settingsVC]
    }
    
    private func createTabBar<T: UIViewController>(_ type: T.Type, title: String, imageName: String, completion: ((T) -> Void)? = nil) -> T {
        
        let vc = T.loadFromStoryboard
        vc.tabBarItem.title = title
        vc.tabBarItem.image = UIImage(systemName: imageName)
        
        completion?(vc)
        return vc
    }
    
    private func configureImageDarkMode() {
        view.addSubview(imageView)
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        trailConstraint = imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -54)
        leadConstraint = imageView.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        leadConstraint?.isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
    }

    private func configureView() {
        configureTabBar()
        configureImageDarkMode()
    }
    
    private func fireBase() {
        ///FavoritePodcast
        FirebaseDatabase.shared.observe(
            
            add: { [weak self] (result: Result<FavoritePodcast>) in
                switch result {
                case .success(result: _) :
                    return
                case .failure(error: let error):
                    error.showAlert(vc: self)
                }
            },
            
            remove: { [weak self] (result: Result<FavoritePodcast>) in
                switch result {
                case .success(result: _):
                    return
                case .failure(error: let error):
                    error.showAlert(vc: self)
                }
                
            })
        
        ///LikedMoment
        FirebaseDatabase.shared.observe(
            add: { [weak self] (result: Result<LikedMoment>) in
                switch result {
                case .success(result: let likedMoment) :
                    likedMoment.saveInCoredataIfNotSaved()
                case .failure(error: let error):
                    error.showAlert(vc: self)
                }
            }, remove: { [weak self] (result: Result<LikedMoment>) in
                switch result {
                case .success(result: let likedMoment):
                    likedMoment.removeFromCoreData()
                case .failure(error: let error):
                    error.showAlert(vc: self)
                }
            })
        
        ///LikedMoment
        FirebaseDatabase.shared.observe(
            add: { [weak self] (result: Result<ListeningPodcast>) in
                switch result {
                case .success(result: let listeningPodcast) :
                    listeningPodcast.saveInCoredataIfNotSaved()
                case .failure(error: let error):
                    error.showAlert(vc: self)
                }
            }, remove: { [weak self] (result: Result<ListeningPodcast>) in
                switch result {
                case .success(result: let listeningPodcast):
                    listeningPodcast.removeFromCoreData()
                case .failure(error: let error):
                    error.showAlert(vc: self)
                }
            })
    }
    
    private func feedbackGenerator() {
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
}

// MARK: - PlaylistTableViewControllerDelegate
extension TabBarViewController: FavoritePodcastViewControllerDelegate {
    
    func favoritePodcastTableViewController(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, playlist: [Podcast], podcast: Podcast) {
        startPlay(track: podcast, playlist: playlist)
    }
    
    func favoritePodcastTableViewControllerDidSelectDownLoadImage(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, podcast: Podcast) {
        downloadOrRemovePodcast(vc: favoritePodcastTableViewController, entity: podcast)
    }
    
    func favoritePodcastTableViewControllerDidSelectStar(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, podcast: Podcast) {
        addOrRemoveFavoritePodcast(vc: favoritePodcastTableViewController,podcast: podcast)
    }
    
    func favoritePodcastTableViewControllerDidSelectCell(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, podcast: Podcast) {
        presentDetailViewController(podcast: podcast)
    }
}

// MARK: - SearchViewControllerDelegate
extension TabBarViewController: SearchViewControllerDelegate {
    
    func searchViewControllerDidSelectCell(_ searchViewController: SearchViewController, podcast: Podcast) {
        presentDetailViewController(podcast: podcast)
    }
    
    func searchViewControllerDidSelectFavoriteStar(_ searchViewController: SearchViewController, podcast: Podcast) {
        addOrRemoveFavoritePodcast(vc: searchViewController,podcast: podcast)
    }
    
    func searchViewControllerDidSelectDownLoadImage(_ searchViewController: SearchViewController, entity: DownloadProtocol, completion: @escaping () -> Void) {
        downloadOrRemovePodcast(vc: searchViewController, entity: entity)
    }
    
    func searchViewController(_ searchViewController: SearchViewController, _ playlist: [InputPlayerProtocol], track: InputPlayerProtocol) {
        startPlay(track: track, playlist: playlist)
    }
}

// MARK: - SettingsTableViewControllerDelegate
extension TabBarViewController: SettingsTableViewControllerDelegate {
    
    func settingsTableViewControllerDidAppear(_ settingsTableViewController: SettingsTableViewController) {
        self.smallPlayer.isHidden = true
    }
    
    func settingsTableViewControllerDidDisappear(_ settingsTableViewController: SettingsTableViewController) {
        if self.player.currentTrack != nil {
            self.smallPlayer.isHidden = false
        }
    }
}



//MARK: - SmallPlayerViewControllerDelegate
extension TabBarViewController: SmallPlayerViewControllerDelegate {
    
    func smallPlayerViewControllerDidTouchPlayStopButton(_ smallPlayerViewController: SmallPlayerView) {
        player.playOrPause()
    }
    
    func smallPlayerViewControllerSwipeOrTouch(_ smallPlayerViewController: SmallPlayerView) {
        presentBigPlayer(for: self)
    }
}

//MARK: - BigPlayerViewControllerDelegate
extension TabBarViewController: BigPlayerViewControllerDelegate {
    
    func bigPlayerViewControllerDidTouchPodcastNameLabel(_ bigPlayerViewController: BigPlayerViewController, track: InputPlayerProtocol?) {
        guard let podcast = track as? Podcast else { return }
        bigPlayerViewController.dismiss(animated: true)
        presentDetailViewController(podcast: podcast) { [weak self] in
                self?.detailViewController.scrollToCell(id: podcast.identifier)
        }
    }
    
    func bigPlayerViewControllerDidSelectPlayStopButton(_ bigPlayerViewController: BigPlayerViewController) {
        player.playOrPause()
    }
    
    func bigPlayerViewControllerDidSelectNextTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        player.playNextPodcast()
    }
    
    func bigPlayerViewControllerDidSelectPreviewsTrackButton(_ bigPlayerViewController: BigPlayerViewController) {
        player.playPreviewsTrack()
    }
    
    func bigPlayerViewController(_ bigPlayerViewController: BigPlayerViewController, didChangeCurrentTime value: Double) {
        player.playerSeek(to: value)
    }
    
    func bigPlayerViewController(_ bigPlayerViewController: BigPlayerViewController, didRewindCurrentTime value: Double) {
        player.playerRewindSeek(to: value)
    }
    
    func bigPlayerViewController(_ bigPlayerViewController: BigPlayerViewController, didLikeThis moment: Double) {
        if let podcast = player.currentTrack?.track as? Podcast {
            LikedMoment(podcast: podcast, moment: moment)
        }
    }
}


// MARK: - DetailViewControllerDelegate
extension TabBarViewController : DetailViewControllerDelegate {
    
    func detailViewControllerPlayStopButtonDidTouchInSmallPlayer(_ detailViewController: DetailViewController) {
        player.playOrPause()
    }
    
    func detailViewControllerDidSwipeOnPlayer(_ detailViewController: DetailViewController) {
        presentBigPlayer(for: detailViewController)
    }
    
    func detailViewControllerPlayButtonDidTouchFor(_ detailViewController: DetailViewController, podcast: Podcast, playlist: [Podcast]) {
        playerIsPresent(true)
        startPlay(track: podcast, playlist: playlist)
    }
    
    func detailViewControllerStopButtonDidTouchFor(_ detailViewController: DetailViewController, podcast: Podcast) {
        player.playOrPause()
    }
    
    func detailViewController(_ detailViewController: DetailViewController, addToFavoriteButtonDidTouchFor podcast: Podcast) {
        addOrRemoveFavoritePodcast(vc: detailViewController, podcast: podcast)
    }
    
    func detailViewController(_ detailViewController: DetailViewController, removeFromFavoriteButtonDidTouchFor selectedPodcast: Podcast) {
        addOrRemoveFavoritePodcast(vc: detailViewController, podcast: selectedPodcast)
    }
    
    func detailViewControllerDidSelectDownLoadImage(_ detailViewController: DetailViewController, entity: DownloadProtocol) {
        downloadOrRemovePodcast(vc: detailViewController, entity: entity)
    }
}

//MARK: - UIViewControllerTransitioningDelegate
extension TabBarViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }
}

extension TabBarViewController: DownloadServiceDelegate {
    
    private var downloadViewControllers: [DownloadServiceDelegate] {
        var viewControllers = [UIViewController]()
        
        self.viewControllers?.forEach {
            if let navigationController = $0 as? UINavigationController {
                navigationController.viewControllers.forEach {
                    viewControllers.append($0)
                    return
                }
            }
            viewControllers.append($0)
        }
        viewControllers.append(detailViewController)
        return viewControllers.compactMap { $0 as? DownloadServiceDelegate }
    }
    
    func updateDownloadInformation(_ downloadService: DownloadService, entity: DownloadServiceType) {
        downloadViewControllers.forEach {
            $0.updateDownloadInformation(downloadService, entity: entity)
        }
    }
    
    func didEndDownloading(_ downloadService: DownloadService, entity: DownloadServiceType) {
        downloadViewControllers.forEach {
            $0.didEndDownloading(downloadService, entity: entity)
        }
    }
    
    func didPauseDownload(_ downloadService: DownloadService, entity: DownloadServiceType) {
        downloadViewControllers.forEach {
            $0.didPauseDownload(downloadService, entity: entity)
        }
    }
    
    func didContinueDownload(_ downloadService: DownloadService, entity: DownloadServiceType) {
        downloadViewControllers.forEach {
            $0.didContinueDownload(downloadService, entity: entity)
        }
    }
    
    func didStartDownload(_ downloadService: DownloadService, entity: DownloadServiceType) {
        downloadViewControllers.forEach {
            $0.didStartDownload(downloadService, entity: entity)
        }
    }
    
    func didRemoveEntity(_ downloadService: DownloadService, entity: DownloadServiceType) {
        downloadViewControllers.forEach {
            $0.didRemoveEntity(downloadService, entity: entity)
        }
    }
}

