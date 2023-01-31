

import UIKit
import CoreData

class TabBarViewController: UITabBarController {
    
    // MARK: - View
    private let downloadService = DownloadService()
    lazy private var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "BackGroundSession")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    private var trailConstraint: NSLayoutConstraint?
    private var leadConstraint: NSLayoutConstraint?
    
    lazy private var constraintsSmallPlayer: [NSLayoutConstraint] = [
        playerVC.view.heightAnchor.constraint(equalToConstant: 50),
        playerVC.view.widthAnchor.constraint(equalTo: view.widthAnchor),
        playerVC.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
    ]
    
    lazy private var imageView: UIImageView =  {
        $0.image = UIImage(named: "decree")
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView())
    
    private var playerVC = PlayerViewController()
    private var userViewModel: UserViewModel!
    private let firestorageDatabase = FirestorageDatabase()
    
    lazy private var playListVC = createTabBar(PlaylistTableViewController.self , title: "Playlist", imageName: "folder.fill") {
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
        
    //MARK: - METHODS
    func setUserViewModel(_ userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
    }
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        addPlayer()
        configureImageDarkMode()
        downloadService.downloadsSession = downloadsSession
        
        let favDoc = FavoriteDocument.shared

        FirebaseDatabase.shared.observe(add: LikedMoment.addFromFireBase, remove: LikedMoment.removeFromFireBase)
        FirebaseDatabase.shared.observe(add: favDoc.addFromFireBase, remove: favDoc.removeFromFireBase)
        FavoriteDocument.shared.updateFavoritePodcastFromFireBase(completion: nil)
        LikedMoment.updateLikedMomentsFromFireBase {}
    }
}

//MARK: - Private methods
extension TabBarViewController {
    
    private func configureTabBar() {
        viewControllers = [playListVC, searchVC, likedMomentVc, settingsVC]
    }
    
    private func createTabBar<T: UIViewController>(_ type: T.Type, title: String, imageName: String, completion: ((T) -> Void)? = nil) -> T {
       
        let vc = T.initVC
        vc.tabBarItem.title = title
        vc.tabBarItem.image = UIImage(systemName: imageName)
        
        completion?(vc)
        return vc
    }
    
    private func addPlayer() {
        playerVC.view.isHidden = true
        playerVC.view.layer.borderColor = UIColor.gray.cgColor
        playerVC.view.layer.borderWidth = 0.3
        playerVC.view.layer.shadowRadius = 3
        playerVC.view.layer.shadowColor = UIColor.black.cgColor
        playerVC.view.layer.shadowOpacity = 1
        playerVC.view.layer.shadowOffset = .zero
        self.addChild(playerVC)
        view.addSubview(playerVC.view)
        playerVC.view.translatesAutoresizingMaskIntoConstraints = false
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
        FavoriteDocument.shared.addOrRemoveToFavorite(podcast: podcast)
        if FavoriteDocument.shared.isDownload(podcast) { downloadService.cancelDownload(podcast: podcast) }
        feedbackGenerator()
    }
    
    private func downloadOrRemovePodcast(_ podcast: Podcast) {
        if FavoriteDocument.shared.isDownload(podcast) {
            downloadService.cancelDownload(podcast: podcast)
        } else {
            downloadService.startDownload(podcast)
        }
        feedbackGenerator()
    }
    
    private func startPlay(at index: Int, at moment: Double? = nil, playlist: [Podcast]) {
        playerVC.startPlay(at: index, at: moment, playlist: playlist)
        playerIsHidden(false)
    }
    
    private func playerIsHidden(_ bool: Bool) {
        playerVC.view.isHidden = bool
        playListVC.playerIsHidden(bool)
        searchVC.playerIsHidden(bool)
        likedMomentVc.playerIsHidden(bool)
    }
}

// MARK: - SearchViewControllerDelegate
extension TabBarViewController: SearchViewControllerDelegate {
    
    func searchViewControllerDidSelectFavoriteStar(_ searchViewController: SearchViewController, podcast: Podcast) {
        addOrRemoveFavoritePodcast(podcast: podcast)
    }
    
    func searchViewControllerDidSelectDownLoadImage(_ searchViewController: SearchViewController, podcast: Podcast) {
        downloadOrRemovePodcast(podcast)
    }
    
    func searchViewController(_ searchViewController: SearchViewController, _ podcasts: [Podcast], didSelectIndex: Int) {
        startPlay(at: didSelectIndex, playlist: podcasts)
    }
}

// MARK: - PlaylistTableViewControllerDelegate
extension TabBarViewController: PlaylistViewControllerDelegate {
    
    func playlistTableViewControllerDidSelectStar(_ playlistTableViewController: PlaylistTableViewController, favoritePodcast: FavoritePodcast) {
        let podcast = favoritePodcast.podcast
        addOrRemoveFavoritePodcast(podcast: podcast)
    }
    
    func playlistTableViewControllerDidSelectDownLoadImage(_ playlistTableViewController: PlaylistTableViewController, podcast: Podcast) {
        downloadOrRemovePodcast(podcast)
    }
    
    func playlistTableViewController(_ playlistTableViewController: PlaylistTableViewController, podcasts: [Podcast], didSelectIndex: Int) {
        startPlay(at: didSelectIndex, playlist: podcasts)
    }
}

// MARK: - SettingsTableViewControllerDelegate
extension TabBarViewController: SettingsTableViewControllerDelegate {
    
    func settingsTableViewControllerDidAppear(_ settingsTableViewController: SettingsTableViewController) {
        self.playerVC.view.isHidden = true
    }
    
    func settingsTableViewControllerDidDisappear(_ settingsTableViewController: SettingsTableViewController) {
        if self.playerVC.currentPodcast != nil {
            self.playerVC.view.isHidden = false
        }
    }
}

//MARK: - LikedMomentsViewControllerDelegate
extension TabBarViewController: LikedMomentsViewControllerDelegate {
    
    func likedMomentViewController(_ likedMomentViewController: LikedMomentsViewController, didSelectMomentAt index: Int, likedMoments: [LikedMoment]) {
        let moment = likedMoments[index].moment
        let podcast = likedMoments[index].podcast
        startPlay(at: .zero, at: moment, playlist: [podcast])
    }
}

//MARK: - URLSessionDownloadDelegate
extension TabBarViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session                  : URLSession,
                    downloadTask               : URLSessionDownloadTask,
                    didWriteData bytesWritten  : Int64,
                    totalBytesWritten          : Int64,
                    totalBytesExpectedToWrite  : Int64) {
        
        guard let url = downloadTask.originalRequest?.url,
              let podcastDownload = downloadService.activeDownloads[url] else { return }
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        let id = podcastDownload.id
        
        DispatchQueue.main.async {
            self.searchVC.updateDisplay(progress: progress, totalSize: totalSize, id: id)
            self.playListVC.updateDisplay(progress: progress, totalSize: totalSize, id: id)
        }
    }
    
    
    
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
        
        let podcastID = downloadService.activeDownloads[url]?.id
     
        DispatchQueue.main.async {
            self.downloadService.endDownload(url: url)
            
            if let id = podcastID, let indexPath = FavoriteDocument.shared.getIndexPath(id: id) {
                self.playListVC.reloadData(indexPath: [indexPath])
                self.searchVC.reloadData(indexPath: [indexPath])
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
