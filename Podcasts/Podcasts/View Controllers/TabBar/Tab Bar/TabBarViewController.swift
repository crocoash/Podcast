

import UIKit
import CoreData

class TabBarViewController: UITabBarController {
    
    private var downloadService = DownloadService.shared
    
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
    
    lazy private var activityIndicator: UIActivityIndicatorView = {
        $0.hidesWhenStopped = true
        $0.isHidden = true
        $0.stopAnimating()
        $0.style = .large
        $0.color = .white
        $0.center = view.center
        return $0
    }(UIActivityIndicatorView())
    
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
        downloadService.configureURLSession(delegate: self)
    }
}

//MARK: - Private methods
extension TabBarViewController {
    
    private func addOrRemoveFavoritePodcast(podcast: Podcast) {
        podcast.addOrRemoveToFavorite()
        if podcast.stateOfDownload == .isDownload { downloadService.cancelDownload(podcast) }
        feedbackGenerator()
    }
    
    private func downloadOrRemovePodcast(for vc: UIViewController, entity: DownloadServiceProtocol ,completion: @escaping () -> Void) {
        downloadService.conform(vc: vc, entity: entity, completion: completion)
    }
    
    private func startPlay(track: InputPlayerProtocol, at moment: Double? = nil, playlist: [InputPlayerProtocol]) {
        player.startPlay(track: track, playList: playlist, at: moment)
        playerIsPresent(true)
    }
    
    private func playerIsPresent(_ value: Bool) {
        smallPlayer.isHidden = !value
        favoritePodcastVC.updateConstraintForTableView(playerIsPresent: value)
        searchVC.updateConstraintForTableView(playerIsPresent: value)
        likedMomentVc.updateConstraintForTableView(playerIsPresent: value)
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
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            ApiService.getData(for: DynamicLinkManager.podcastById(id).url) { [weak self] (result : Result<PodcastData>) in
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                switch result {
                case .failure(error: let error):
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
        self.viewControllers = [favoritePodcastVC, searchVC, likedMomentVc, settingsVC]
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
        view.addSubview(activityIndicator)
    }
    
    private func fireBase() {
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
                    favoritePodcast.remove()
                case .failure(error: let error):
                    error.showAlert(vc: self, tittle: "Can't remove FavoritePodcast")
                }
            })
        
        FavoritePodcast.updateFromFireBase { [weak self] result in
            switch result {
            case .failure(error: let error) :
                error.showAlert(vc: self)
            default: break
            }
        }
        
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
                    likedMoment.remove()
                case .failure(error: let error):
                    error.showAlert(vc: self, tittle: "Can't remove likedMoment")
                }
            })

        LikedMoment.updateFromFireBase { [weak self] result in
            switch result {
            case .failure(error: let error) :
                error.showAlert(vc: self)
            default: break
            }
        }
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
    
    func searchViewControllerDidSelectDownLoadImage(_ searchViewController: SearchViewController, entity: DownloadServiceProtocol, completion: @escaping () -> Void) {
        downloadOrRemovePodcast(for: self, entity: entity, completion: completion)
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
                self?.detailViewController.scrollToCell(id: track?.id)
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
            LikedMoment.saveInCoredataIfNotSaved(podcast: podcast, moment: moment)
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
    
    func detailViewControllerPlayButtonDidTouchFor(_ detailViewController: DetailViewController, podcast: Podcast, at moment: Double?, playlist: [Podcast]) {
        playerIsPresent(true)
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
    
    func detailViewControllerDidSelectDownLoadImage(_ detailViewController: DetailViewController, entity: DownloadServiceProtocol, completion: @escaping () -> Void) {
        downloadOrRemovePodcast(for: detailViewController, entity: entity ,completion: completion)
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
