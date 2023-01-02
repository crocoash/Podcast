

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
    
    private var playerISShow = false
    
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
        FirebaseDatabase.shared.observe()
        FirebaseDatabase.shared.delegate = self
    }
}

//MARK: -Private methods
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
    
    private func addOrRemoveFromFavorite(podcast: Podcast) {
        let isFavorite = FavoriteDocument.shared.isFavorite(podcast)
        let title = (podcast.trackName ?? "podcast") + (isFavorite ? "is removed from playlist" : "is added to playlist")
        MyToast.create(title: title, (playerISShow ? .bottomWithPlayer : .bottom), animateWithDuration: 0.2,timerToRemove: 2,for: view)

        FavoriteDocument.shared.addOrRemoveToFavorite(podcast: podcast)
        if FavoriteDocument.shared.isDownload(podcast: podcast) { downloadService.cancelDownload(podcast: podcast) }
        feedbackGenerator()
    }
    
    private func downloadOrRemovePodcast(_ podcast: Podcast, _ indexPath: IndexPath) {
        if FavoriteDocument.shared.isDownload(podcast: podcast) {
            downloadService.cancelDownload(podcast: podcast)
            reloadAllVC()
        } else {
            downloadService.startDownload(podcast, indexPath: indexPath)
        }
        feedbackGenerator()
    }
    
    private func startPlay(_ podcasts: [Podcast], _ didSelectIndex: Int) {
        playerVC.view.isHidden = false
        playerVC.playLikedPlaylist(at: didSelectIndex, likedPlaylist: podcasts)
    }
    
    private func reloadAllVC() {
        self.searchVC.reloadData()
        self.playListVC.reloadData()
    }
    
    private func playerIsShow() {
        playerISShow = true
        playListVC.playerIsShow()
        searchVC.playerIsShow()
        likedMomentVc.playerIsShow()
    }
}

// MARK: ------------- SearchViewControllerDelegate
extension TabBarViewController: SearchViewControllerDelegate {
    
    func searchViewControllerDidSelectFavoriteStar(_ searchViewController: SearchViewController, podcast: Podcast) {
        addOrRemoveFromFavorite(podcast: podcast)
    }
    
    func searchViewControllerDidRefreshTableView(_ searchViewController: SearchViewController, completion: @escaping () -> Void) {
        
    }
    
    
    func searchViewControllerDidSelectDownLoadImage(_ searchViewController: SearchViewController, podcast: Podcast, indexPath: IndexPath) {
        downloadOrRemovePodcast(podcast, indexPath)
    }
    
    func searchViewController(_ searchViewController: SearchViewController, _ podcasts: [Podcast], didSelectIndex: Int) {
        startPlay(podcasts, didSelectIndex)
        playerIsShow()
    }
}

// MARK: - PlaylistTableViewControllerDelegate
extension TabBarViewController: PlaylistViewControllerDelegate {
    
    func playlistTableViewControllerDidRefreshTableView(_ playlistTableViewController: PlaylistTableViewController, completion: @escaping () -> Void) {
        FirebaseDatabase.shared.getFavoritePodcast { [weak self] in
            guard let self = self else { return }
            MyToast.create(title: "favorite podcast was updating", (self.playerISShow ? .bottomWithPlayer : .bottom), animateWithDuration: 0.2,timerToRemove: 2,for: playlistTableViewController.view)
            completion()
        }
    }
    
    func playlistTableViewControllerDidSelectStar(_ playlistTableViewController: PlaylistTableViewController, podcast: Podcast) {
        addOrRemoveFromFavorite(podcast: podcast)
    }
    
    func playlistTableViewControllerDidSelectDownLoadImage(_ playlistTableViewController: PlaylistTableViewController, podcast: Podcast) {
        guard let indexPath = FavoriteDocument.shared.getIndexPath(for: podcast) else { return }
        downloadOrRemovePodcast(podcast, indexPath)
    }
    
    func playlistTableViewController(_ playlistTableViewController: PlaylistTableViewController, podcasts: [Podcast], didSelectIndex: Int) {
        startPlay(podcasts, didSelectIndex)
        playerIsShow()
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
        playerVC.view.isHidden = false
        let moment = likedMoments[index].moment
        let podcast = likedMoments[index].podcast
        playerVC.playLikedPlaylist(at: 0, at: moment, likedPlaylist: [podcast])
        playerIsShow()
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
        
        DispatchQueue.main.async {
            self.downloadService.endDownload(url: url)
            self.reloadAllVC()
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

//MARK: - FirebaseDatabaseDelegate
extension TabBarViewController: FirebaseDatabaseDelegate {

    func firebaseDatabaseDidGetData(_ firebaseDatabase: FirebaseDatabase) {
        playListVC.reloadData()
        searchVC.reloadData()
        likedMomentVc.reloadData()
        feedbackGenerator()
    }
}
