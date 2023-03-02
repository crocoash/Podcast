

import UIKit
import CoreData

class TabBarViewController: UITabBarController {
    
    private var downloadService = DownloadService.shared
    
    // MARK: - View
    
    private var trailConstraint: NSLayoutConstraint?
    private var leadConstraint: NSLayoutConstraint?
    
    lazy private var constraintsSmallPlayer: [NSLayoutConstraint] = [
        smallPlayer.view.heightAnchor.constraint(equalToConstant: 50),
        smallPlayer.view.widthAnchor.constraint(equalTo: view.widthAnchor),
        smallPlayer.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
    ]
    
    lazy private var player: Player = {
        $0.delegate = self
        return $0
    }(Player())
    
    lazy private var imageView: UIImageView =  {
        $0.image = UIImage(named: "decree")
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView())
    
    private var smallPlayer = SmallPlayerViewController()
    private var userViewModel: UserViewModel!
    private let firestorageDatabase = FirestorageDatabase()
    
    lazy private var favoritePodcastVC = createTabBar(FavoritePodcastTableViewController.self , title: "Playlist", imageName: "folder.fill") {
        $0.delegate = self
    }
    lazy private var searchVC = createTabBar(SearchViewController.self, title: "Search", imageName: "magnifyingglass") {
        $0.delegate = self
    }
    lazy private var likedMomentVc = createTabBar(LikedMomentsViewController.self , title: "Liked", imageName: "heart.fill") {
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
    }(DetailViewController.initVC)

    private var bigPlayerVc: BigPlayerViewController?
    
    //MARK: - METHODS
    func setUserViewModel(_ userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
    }
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        configureSmallPlayer()
        presentPlayer(for: self)
        configureImageDarkMode()
        downloadService.configureURLSession(delegate: self)
        
        ///FavoritePodcast
        FirebaseDatabase.shared.observe(
            add: { [weak self] (result: Result<FavoritePodcast>) in
                switch result {
                case .success(result: let favoritePodcast) :
                    favoritePodcast.saveInCoredataIfNotSaved()
                case .failure(error: let error):
                    error.showAlert(vc: self, tittle: "Can't add FavoritePodcast")
                }
            }, remove: { [weak self] (result: Result<FavoritePodcast>) in
                switch result {
                case .success(result: let favoritePodcast):
                    favoritePodcast.removeFromCoreData()
                case .failure(error: let error):
                    error.showAlert(vc: self, tittle: "Can't remove FavoritePodcast")
                }
            })
        
        ///LikedMoment
        FirebaseDatabase.shared.observe(
            add: { [weak self] (result: Result<LikedMoment>) in
                switch result {
                case .success(result: let likedMoment) :
                    likedMoment.saveInCoredataIfNotSaved()
                case .failure(error: let error):
                    error.showAlert(vc: self, tittle: "Can't add likedMoment")
                }
            }, remove: { [weak self] (result: Result<LikedMoment>) in
                switch result {
                case .success(result: let likedMoment):
                    likedMoment.removeFromCoreData()
                case .failure(error: let error):
                    error.showAlert(vc: self, tittle: "Can't remove likedMoment")
                }
            })
        
        FavoritePodcast.updateFromFireBase { [weak self] result in
            switch result {
            case .failure(error: let error) :
                error.showAlert(vc: self)
            default: break
            }
        }
        
        LikedMoment.updateFromFireBase { [weak self] result in
            switch result {
            case .failure(error: let error) :
                error.showAlert(vc: self)
            default: break
            }
        }
    }
}

//MARK: - Private methods
extension TabBarViewController {
    
    private func configureTabBar() {
        viewControllers = [favoritePodcastVC, searchVC, likedMomentVc, settingsVC]
    }
    
    private func createTabBar<T: UIViewController>(_ type: T.Type, title: String, imageName: String, completion: ((T) -> Void)? = nil) -> T {
        
        let vc = T.initVC
        vc.tabBarItem.title = title
        vc.tabBarItem.image = UIImage(systemName: imageName)
        
        completion?(vc)
        return vc
    }
    
    private func configureSmallPlayer() {
        //        smallPlayer.view.isHidden = true
        smallPlayer.view.layer.borderColor = UIColor.gray.cgColor
        smallPlayer.view.layer.borderWidth = 0.3
        smallPlayer.view.layer.shadowRadius = 3
        smallPlayer.view.layer.shadowColor = UIColor.black.cgColor
        smallPlayer.view.layer.shadowOpacity = 1
        smallPlayer.view.layer.shadowOffset = .zero
        smallPlayer.delegate = self
        player.smallPlayerDelegate = self
        //        addChild(smallPlayer)
        smallPlayer.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func presentPlayer(for vc: UIViewController) {
        vc.addChild(smallPlayer)
        vc.view.addSubview(smallPlayer.view)
        NSLayoutConstraint.activate(constraintsSmallPlayer)
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
    
    private func feedbackGenerator() {
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
    private func addOrRemoveFavoritePodcast(podcast: Podcast) {
        podcast.addOrRemoveToFavorite()
        if podcast.stateOfDownload == .isDownload { downloadService.cancelDownload(podcast) }
        feedbackGenerator()
    }
    
    private func downloadOrRemovePodcast(for vc: UIViewController, _ entity: DownloadServiceProtocol, completion: @escaping () -> Void) {
        switch entity.stateOfDownload {
            
        case .notDownloaded:
            downloadService.startDownload(vc: vc, entity)
            
        case .isDownloading:
            self.downloadService.pauseDownload(entity)
            Alert().create(for: vc, title: "Do you want cancel downloading ?") { [weak self] _ in
                [UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                    self?.downloadService.cancelDownload(entity)
                    completion()
                }, UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
                    self?.downloadService.continueDownload(entity)
                    completion()
                }]
            }
            
        case .isDownload:
            Alert().create(for: vc, title: "Do you want remove podcast from your device?") { [weak self] _ in
                [UIAlertAction(title: "yes", style: .destructive) { [weak self] _ in
                    self?.downloadService.cancelDownload(entity)
                    completion()
                }, UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    completion()
                }
                ]
            }
        }
        
        feedbackGenerator()
    }
    
    private func startPlay(track: InputPlayerProtocol, at moment: Double? = nil, playlist: [InputPlayerProtocol]) {
        player.startPlay(track: track, playList: playlist, at: moment)
        playerIsHidden(false)
    }
    
    private func playerIsHidden(_ value: Bool) {
        smallPlayer.view.isHidden = value
        favoritePodcastVC.updateConstraintForTableView(playerIsPresent: value)
        searchVC.updateConstraintForTableView(playerIsPresent: value)
        likedMomentVc.updateConstraintForTableView(playerIsPresent: value)
    }
    
    private func presentDetailViewController(podcast: Podcast, completion: (() -> Void)? = nil) {
        if detailViewController.podcast == podcast {
            self.present(self.detailViewController, animated: true, completion: completion)
        } else {
            guard let id = podcast.collectionId?.stringValue else { return }
            ApiService.getData(for: DinamicLinkManager.podcastById(id).url) { [weak self] (result : Result<PodcastData>) in
                guard let self = self else { return }
                switch result {
                case .failure(error: let error):
                    error.showAlert(vc: self)
                case .success(result: let podcastData) :
                    let podcasts = podcastData.podcasts.filter { $0.wrapperType == "podcastEpisode"}
                    self.detailViewController.setUp(podcast: podcast, playlist: podcasts)
                    self.present(self.detailViewController,animated: true, completion: completion)
                }
            }
        }
    }
    
    private func presentBigPlayer() {
        self.bigPlayerVc = configureBigPlayer()
        guard let bigPlayerVc = bigPlayerVc else { return }
        present(bigPlayerVc, animated: true)
        self.bigPlayerVc?.setUpUI(with: player)
    }
    
    private func configureBigPlayer() -> BigPlayerViewController {
        let bigPlayerVC = BigPlayerViewController.loadFromXib()
        bigPlayerVC.delegate = self
        bigPlayerVC.modalPresentationStyle = .fullScreen
        return bigPlayerVC
    }
}

// MARK: - PlaylistTableViewControllerDelegate
extension TabBarViewController: FavoritePodcastViewControllerDelegate {
    
    func favoritePodcastTableViewController(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, playlist: [Podcast], podcast: Podcast) {
        startPlay(track: podcast, playlist: playlist)
    }
    
    func favoritePodcastTableViewControllerDidSelectDownLoadImage(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, podcast: Podcast) {
        //        downloadOrRemovePodcast(for: favoritePodcastTableViewController, podcast, completion: completion)
    }
    
    func favoritePodcastTableViewControllerDidSelectStar(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, podcast: Podcast) {
        addOrRemoveFavoritePodcast(podcast: podcast)
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
        addOrRemoveFavoritePodcast(podcast: podcast)
    }
    
    func searchViewControllerDidSelectDownLoadImage(_ searchViewController: SearchViewController, podcast: Podcast, completion: @escaping () -> Void) {
        downloadOrRemovePodcast(for: searchViewController, podcast, completion: completion)
    }
    
    func searchViewController(_ searchViewController: SearchViewController, _ playlist: [InputPlayerProtocol], track: InputPlayerProtocol) {
        startPlay(track: track, playlist: playlist)
    }
}

// MARK: - SettingsTableViewControllerDelegate
extension TabBarViewController: SettingsTableViewControllerDelegate {
    
    func settingsTableViewControllerDidAppear(_ settingsTableViewController: SettingsTableViewController) {
//        presentPlayer(for: settingsTableViewController)
        self.smallPlayer.view.isHidden = true
    }
    
    func settingsTableViewControllerDidDisappear(_ settingsTableViewController: SettingsTableViewController) {
        if self.player.currentTrack != nil {
            self.smallPlayer.view.isHidden = false
        }
    }
}

//MARK: - LikedMomentsViewControllerDelegate
extension TabBarViewController: LikedMomentsViewControllerDelegate {
    
    func likedMomentViewController(_ likedMomentViewController: LikedMomentsViewController, didSelectMomentAt index: Int, likedMoments: [LikedMoment]) {
        let moment = likedMoments[index].moment
        let podcast = likedMoments[index].podcast
        startPlay(track: podcast, at: moment, playlist: [podcast])
    }
}

//MARK: - URLSessionDownloadDelegate
extension TabBarViewController: URLSessionDownloadDelegate {
    
    ///downloadTask
    func urlSession(_ session                  : URLSession,
                    downloadTask               : URLSessionDownloadTask,
                    didWriteData bytesWritten  : Int64,
                    totalBytesWritten          : Int64,
                    totalBytesExpectedToWrite  : Int64) {
        
        guard let url = downloadTask.originalRequest?.url,
              let entity = downloadService.activeDownloads[url] else { return }
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        
        if let podcast = entity.downloadServiceProtocol as? Podcast {
            DispatchQueue.main.async {
                self.searchVC.updateDownloadInformation(progress: progress, totalSize: totalSize, podcast: podcast)
                self.favoritePodcastVC.updateDownloadInformation(progress: progress, totalSize: totalSize, podcast: podcast)
                self.detailViewController.updateDownloadInformation(progress: progress, totalSize: totalSize, for: podcast)
            }
        }
    }
    
    ///didFinishDownloadingTo
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager.default
        
        guard let url = downloadTask.originalRequest?.url else { return }
        let localPath = url.localPath
        
        do {
            try fileManager.copyItem(at: location, to: localPath)
        } catch {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        do {
            try fileManager.removeItem(at: location)
        } catch {
            print("Could not remove item at disk: \(error.localizedDescription)")
        }
        
        guard let entity = downloadService.activeDownloads[url]?.downloadServiceProtocol else { return }
        
        DispatchQueue.main.async {
            self.downloadService.endDownload(entity)
            
            if let podcast = entity as? Podcast {
                self.favoritePodcastVC.endDownloading(podcast: podcast)
                self.searchVC.endDownloading(podcast: podcast)
                self.detailViewController.endDownloading(podcast: podcast)
            }
        }
    }
}

//MARK: - URLSessionDelegate
extension TabBarViewController: URLSessionDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}

//MARK: - SmallPlayerViewControllerDelegate
extension TabBarViewController: SmallPlayerViewControllerDelegate {
    
    func smallPlayerViewControllerDidTouchPlayStopButton(_ smallPlayerViewController: SmallPlayerViewController) {
        player.playOrPause()
    }
    
    func smallPlayerViewControllerSwipeOrTouch(_ smallPlayerViewController: SmallPlayerViewController) {
        presentBigPlayer()
    }
}

//MARK: - BigPlayerViewControllerDelegate
extension TabBarViewController: BigPlayerViewControllerDelegate {
    
    func bigPlayerViewControllerDidTouchPodcastNameLabel(_ bigPlayerViewController: BigPlayerViewController, track: InputPlayerProtocol?) {
        guard let podcast = track as? Podcast else { return }
        bigPlayerViewController.dismiss(animated: true)
        presentDetailViewController(podcast: podcast) { [weak self] in
            self?.detailViewController.setOffsetForBigPlayer(id: track?.id)
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
            _ = LikedMoment(podcast: podcast, moment: moment)
        }
    }
}


// MARK: - DetailViewControllerDelegate
extension TabBarViewController : DetailViewControllerDelegate {
    
    func detailViewControllerPlayButtonDidTouchFor(_ detailViewController: DetailViewController, podcast: Podcast, at moment: Double?, playlist: [Podcast]) {
        startPlay(track: podcast, at: moment, playlist: playlist)
    }
    
    func detailViewControllerStopButtonDidTouchFor(_ detailViewController: DetailViewController, podcast: Podcast) {
        player.playOrPause()
    }
    
    func detailViewController(_ detailViewController: DetailViewController, addToFavoriteButtonDidTouchFor podcast: Podcast) {
        addOrRemoveFavoritePodcast(podcast: podcast)
    }
    
    func detailViewController(_ detailViewController: DetailViewController, removeFromFavoriteButtonDidTouchFor selectedPodcast: Podcast) {
        addOrRemoveFavoritePodcast(podcast: selectedPodcast)
    }
    
    func detailViewControllerDidSelectDownLoadImage(_ detailViewController: DetailViewController, podcast: Podcast, completion: @escaping () -> Void) {
        downloadOrRemovePodcast(for: detailViewController, podcast, completion: completion)
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

//MARK: - PlayerDelegate
extension TabBarViewController: PlayerDelegate {
    
    func playerEndPlay(player: OutputPlayerProtocol) {
        detailViewController.playerEndPlay(player: player)
        bigPlayerVc?.playerEndPlay(player: player)
    }
    
    func playerStartLoading(player: OutputPlayerProtocol) {
        smallPlayer.playerIsGoingPlay(player: player)
        bigPlayerVc?.playerIsGoingPlay(player: player)
        detailViewController.playerIsGoingPlay(player: player)
    }
    
    func playerDidEndLoading(player: OutputPlayerProtocol) {
        smallPlayer.playerIsEndLoading(player: player)
        bigPlayerVc?.playerIsEndLoading(player: player)
        detailViewController.playerIsEndLoading(player: player)
    }
    
    func playerUpdatePlayingInformation(player: OutputPlayerProtocol) {
        smallPlayer.updateProgressView(player: player)
        bigPlayerVc?.upDateProgressSlider(player: player)
        detailViewController.updateProgressView(player: player)
    }
    
    func playerStateDidChanged(player: OutputPlayerProtocol) {
        smallPlayer.setPlayStopButton(player: player)
        bigPlayerVc?.setPlayPauseButton(player: player)
        detailViewController.updatePlayStopButton(player: player)
    }
}
