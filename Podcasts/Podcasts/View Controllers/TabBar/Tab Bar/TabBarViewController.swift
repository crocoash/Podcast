

import UIKit
import CoreData

class TabBarViewController: UITabBarController {
    
    // MARK: - variables
    private var trailConstraint: NSLayoutConstraint?
    private var leadConstraint: NSLayoutConstraint?
    
    private var imageView: UIImageView = {
        $0.image = UIImage(named: "decree")
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView())
    
    private var smallPlayer: SmallPlayerView?
    
    private let userViewModel: UserViewModel
    private let firestorageDatabase: FirestorageDatabase
    private let player: Player
    private let downloadService: DownloadService
    private let addToFavoriteManager: FavoriteManager
    private let addToLikeManager: AddToLikeManager
    private let firebaseDataBase: FirebaseDatabase
    private let apiService: ApiService
    private let dataStoreManagerInput: DataStoreManagerInput
    
    lazy private var favoritePodcastVC: FavoriteViewController = {
        let favoritePodcastTableViewController = FavoriteViewController(downloadService: downloadService, player: player, addToFavoriteManager: addToFavoriteManager, firebaseDataBase: firebaseDataBase, dataStoreManagerInput: dataStoreManagerInput)
        
        favoritePodcastTableViewController.transitioningDelegate = self
        modalPresentationStyle = .custom
        
        return createTabBar(favoritePodcastTableViewController, title: "Playlist", imageName: "folder.fill")
    }()
    
    lazy private var searchVC: SearchViewController = SearchViewController.create { [weak self] coder in
        guard let self = self,
              let vc = SearchViewController(coder: coder, self, apiService: apiService)
        else { fatalError() }
        
        vc.transitioningDelegate = self
        modalPresentationStyle = .custom
        
        return createTabBar(vc, title: "Search", imageName: "magnifyingglass")
    }
    
    lazy private var settingsVC: SettingsTableViewController =  SettingsTableViewController.create { [weak self] coder in
        guard let self = self,
              let vc = SettingsTableViewController(coder: coder, userViewModel, firestorageDatabase: firestorageDatabase, apiService: apiService)
        else { fatalError() }
        
        vc.transitioningDelegate = self
        modalPresentationStyle = .custom
        
        return createTabBar(vc, title: "Settings", imageName: "gear")
    }
    
    private var detailViewController: DetailViewController?
    
    lazy private var bigPlayerVc: BigPlayerViewController = {
        $0.delegate = self
        $0.modalPresentationStyle = .fullScreen
        return $0
    }(BigPlayerViewController.loadFromXib)
    
    private func configureDetailViewController(podcast: Podcast, playList: [Podcast]) -> DetailViewController {
        
        let detailViewController: DetailViewController = DetailViewController.create { [weak self] coder in

            guard let self = self else { fatalError() }

            let detailViewController = DetailViewController.init(
                coder: coder,
                self,
                podcast: podcast,
                playlist: playList,
                player: self.player,
                downloadService: self.downloadService,
                addToLikeManager: self.addToLikeManager,
                addToFavoritePodcast: self.addToFavoriteManager)
            
            return detailViewController
        }
        
        self.detailViewController = detailViewController
        return detailViewController
    }
    
    //MARK: init
    init?(coder: NSCoder,
                               userViewModel: UserViewModel,
                               firestorageDatabase: FirestorageDatabase,
                               player: Player,
                               downloadService: DownloadService,
                               addToFavoriteManager: FavoriteManager,
                               addToLikeManager: AddToLikeManager,
                               firebaseDataBase: FirebaseDatabase,
                               apiService: ApiService,
                               dataStoreManagerInput: DataStoreManagerInput) {
        
        self.userViewModel = userViewModel
        self.firestorageDatabase = firestorageDatabase
        self.player = player
        self.downloadService = downloadService
        self.addToFavoriteManager = addToFavoriteManager
        self.addToLikeManager = addToLikeManager
        self.firebaseDataBase = firebaseDataBase
        self.apiService = apiService
        self.dataStoreManagerInput = dataStoreManagerInput
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        player.addObserverPlayerEventNotification(for: self)
    }
}

//MARK: - Private methods
extension TabBarViewController {
    
    private func presentSmallPlayer(with track: (any OutputPlayerProtocol)) {
        guard smallPlayer == nil else { return }
        let model = SmallPlayerViewModel(track)
        let smallPlayer = SmallPlayerView(vc: self, model: model, player: player)
        view.addSubview(smallPlayer)
        smallPlayer.isHidden = false
        self.smallPlayer = smallPlayer
        
        smallPlayer.bottomAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        smallPlayer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        smallPlayer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        favoritePodcastVC.updateConstraintForTableView(playerIsPresent: true)
        searchVC.updateConstraintForTableView(playerIsPresent: true)
    }
    
    private func presentDetailViewController(podcast: Podcast, completion: (() -> Void)? = nil) {
        
        /// don't present new detail vc if it already present ( big player vc )
        guard presentedViewController as? DetailViewController == nil else {
            completion?()
            return
        }
        
        if let detailViewController = detailViewController, detailViewController.podcast == podcast {
            self.present(detailViewController, animated: true, completion: completion)
        } else {
            let id = podcast.downloadEntityIdentifier //guard else { return }
            self.view.showActivityIndicator()
            
            apiService.getData(for: DynamicLinkManager.podcastById(id).url) { [weak self] (result : Result<PodcastData>) in
                guard let self = self else { return }
                self.view.hideActivityIndicator()
                switch result {
                case .failure(let error):
                    error.showAlert(vc: self)
                case .success(result: let podcastData) :
                    let podcasts = podcastData.podcasts.filter { $0.wrapperType == "podcastEpisode"}
                    let detailViewController = configureDetailViewController(podcast: podcast, playList: podcasts)
                    self.present(detailViewController, animated: true, completion: completion)
                }
            }
        }
    }
    
    //MARK: configureView
    private func configureTabBar() {
        let navigationController = UINavigationController(rootViewController: favoritePodcastVC)
        self.viewControllers = [navigationController, searchVC, settingsVC]
    }
    
    private func createTabBar<T: UIViewController>(_ vc: T, title: String, imageName: String) -> T {
        vc.tabBarItem.title = title
        vc.tabBarItem.image = UIImage(systemName: imageName)
        
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
}

// MARK: - SearchViewControllerDelegate
extension TabBarViewController: SearchViewControllerDelegate {
  
    func searchViewControllerDidSelectCell(_ searchViewController: SearchViewController, podcast: Podcast) {
        presentDetailViewController(podcast: podcast)
    }
}

// MARK: - SettingsTableViewControllerDelegate
extension TabBarViewController: SettingsTableViewControllerDelegate {
    
    func settingsTableViewControllerDidAppear(_ settingsTableViewController: SettingsTableViewController) {
        self.smallPlayer?.isHidden = true
    }
    
    func settingsTableViewControllerDidDisappear(_ settingsTableViewController: SettingsTableViewController) {
        if self.player.currentTrack != nil {
            self.smallPlayer?.isHidden = false
        }
    }
}

//MARK: - SmallPlayerViewControllerDelegate
extension TabBarViewController: SmallPlayerViewControllerDelegate {
    
    func smallPlayerViewControllerSwipeOrTouch(_ smallPlayerViewController: SmallPlayerView) {
        guard let track = player.currentTrack?.track  else { return }
        let bigPlayerViewController = BigPlayerViewController(self, player: player, track: track, addToLikeManager: addToLikeManager)
        bigPlayerViewController.modalPresentationStyle = .fullScreen
        self.present(bigPlayerViewController, animated: true)
    }
}

//MARK: - BigPlayerViewControllerDelegate
extension TabBarViewController: BigPlayerViewControllerDelegate {
    
    func bigPlayerViewControllerDidTouchPodcastNameLabel(_ bigPlayerViewController: BigPlayerViewController, entity: NSManagedObject) {
        guard let podcast = entity as? Podcast else { return }
        bigPlayerViewController.dismiss(animated: true)
        presentDetailViewController(podcast: podcast) { [weak self] in
            self?.detailViewController?.scrollToCell(podcast: podcast)
        }
    }
}

// MARK: - DetailViewControllerDelegate
extension TabBarViewController : DetailViewControllerDelegate {}

//MARK: - UIViewControllerTransitioningDelegate
extension TabBarViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }
}

//MARK: - PlayerEventNotification
extension TabBarViewController: PlayerEventNotification {
    
    func playerDidEndPlay(with track: OutputPlayerProtocol) {}
    
    func playerStartLoading(with track: OutputPlayerProtocol) {
        presentSmallPlayer(with: track)
    }
    
    func playerDidEndLoading(with track: OutputPlayerProtocol) {}
    
    func playerUpdatePlayingInformation(with track: OutputPlayerProtocol) {}
    
    func playerStateDidChanged(with track: OutputPlayerProtocol) {}
    
}
