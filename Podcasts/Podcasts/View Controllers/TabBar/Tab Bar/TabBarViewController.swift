

import UIKit
import CoreData

class TabBarViewController: UITabBarController, IHaveStoryBoard {
    
    
    typealias Args = Void
    
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
    private var player: Player
    private let downloadService: DownloadService
    private let favouriteManager: FavouriteManager
    private let likeManager: LikeManager
    private let firebaseDataBase: FirebaseDatabase
    private let apiService: ApiService
    private let dataStoreManager: DataStoreManager
    private let listeningManager: ListeningManager
    private let container: IContainer
    
    lazy private var ListVC: ListViewController = {
        
        let vc: ListViewController = container.resolveWithModel(args: self)
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        return createTabBar(vc, title: "Playlist", imageName: "folder.fill")
    }()
    
    lazy private var searchVC: SearchViewController = {
        let argVM: SearchViewControllerViewModel.Arguments = []
        let vc: SearchViewController = container.resolveWithModel(argsVM: argVM)
        vc.transitioningDelegate = self
        modalPresentationStyle = .custom
        
        return createTabBar(vc, title: "Search", imageName: "magnifyingglass")
    }()
    
    lazy private var settingsVC: SettingsTableViewController = {
        let vc: SettingsTableViewController = container.resolve()
        vc.transitioningDelegate = self
        modalPresentationStyle = .custom
        
        return createTabBar(vc, title: "Settings", imageName: "gear")
    }()

   //MARK: init
    required init?(container: IContainer, args: (args: Args, coder: NSCoder)) {
     
        self.userViewModel = container.resolve()
        self.firestorageDatabase = container.resolve()
        self.player = container.resolve()
        self.downloadService = container.resolve()
        self.favouriteManager = container.resolve()
        self.likeManager = container.resolve()
        self.firebaseDataBase = container.resolve()
        self.apiService = container.resolve()
        self.dataStoreManager = container.resolve()
        self.listeningManager = container.resolve()
        self.container = container

        super.init(coder: args.coder)
    }

    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        self.player.delegate = self
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
        smallPlayer.widthAnchor.constraint(equalTo: tabBar.widthAnchor).isActive = true
        
        ListVC.updateConstraintForTableView(playerIsPresent: true)
        searchVC.updateConstraintForTableView(playerIsPresent: true)
    }
    
    private func configureDetailViewController(podcast: Podcast, playList: [Podcast]) -> DetailViewController {
        
        let args = DetailViewController.Args(podcast: podcast, podcasts: playList)
        let detailViewController: DetailViewController = container.resolve(args: args)
        
        detailViewController.modalPresentationStyle = .custom
        detailViewController.transitioningDelegate = self
        
        return detailViewController
    }
    
    private func presentDetailViewController(podcast: Podcast, completion: ((DetailViewController) -> Void)? = nil) {
        /// don't present new detail vc if it already present ( big player vc )
        
//        if let detailViewController = presentedViewController as? DetailViewController, detailViewController.podcast == podcast {
//            self.present(detailViewController, animated: true)
//            completion?(detailViewController)
//        } else {
            guard let id = podcast.collectionId?.stringValue else { return }
            self.view.showActivityIndicator()
            
            apiService.getData(for: DynamicLinkManager.podcastEpisodeById(id).url) { [weak self] (result : Result<PodcastData>) in
                guard let self = self else { return }
                view.hideActivityIndicator()
                switch result {
                case .failure(let error):
                    error.showAlert(vc: self)
                case .success(result: let podcastData) :
                    let podcasts = podcastData.podcasts.filter { $0.wrapperType == "podcastEpisode"}
                    let detailViewController = configureDetailViewController(podcast: podcast, playList: podcasts)
                    self.present(detailViewController, animated: true)
                    completion?(detailViewController)
                }
//            }
        }
    }
    
    //MARK: configureView
    private func configureTabBar() {
        let navigationController = UINavigationController(rootViewController: ListVC)
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
        guard let track = player.currentTrack?.track else { return }
        let argsVM: BigPlayerViewModel.Arguments = track
        let args: BigPlayerViewController.Arguments = self
        let bigPlayerViewController: BigPlayerViewController = container.resolveWithModel(args: args, argsVM: argsVM)
        bigPlayerViewController.modalPresentationStyle = .fullScreen
        self.present(bigPlayerViewController, animated: true)
    }
}

//MARK: - BigPlayerViewControllerDelegate
extension TabBarViewController: BigPlayerViewControllerDelegate {
    
    func bigPlayerViewControllerDidTouchPodcastNameLabel(_ bigPlayerViewController: BigPlayerViewController, entity: NSManagedObject) {
        guard let podcast = entity as? Podcast else { return }
        presentedViewController?.dismiss(animated: true)
        presentDetailViewController(podcast: podcast) { detail in
            detail.scrollToCell(podcast: podcast)
        }
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

//MARK: - PlayerEventNotification
extension TabBarViewController: PlayerDelegate {
    
    func playerDidEndPlay(_ player: Player, with track: any OutputPlayerProtocol) {}
    
    func playerStartLoading(_ player: Player, with track: any OutputPlayerProtocol) {
        presentSmallPlayer(with: track)
    }
    
    func playerDidEndLoading(_ player: Player, with track: any OutputPlayerProtocol) {}
    
    func playerUpdatePlayingInformation(_ player: Player, with track: any OutputPlayerProtocol) {
        
    }
    
    func playerStateDidChanged(_ player: Player, with track: any OutputPlayerProtocol) {}
}

//MARK: - ListViewControllerDelegate
extension TabBarViewController: ListViewControllerDelegate {
    
    func listViewController(_ listViewController: ListViewController, didSelect podcast: Podcast) {
        presentDetailViewController(podcast: podcast)
    }
}
