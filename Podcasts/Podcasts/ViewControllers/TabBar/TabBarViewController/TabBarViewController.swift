

import UIKit

class TabBarViewController: UITabBarController {
    
    // MARK: - View
    
    let downloadService = DownloadService()
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "BackGroundSession")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    lazy var constraintsSmallPlayer: [NSLayoutConstraint] = [
        playerVC.view.heightAnchor.constraint(equalToConstant: 50),
        playerVC.view.widthAnchor.constraint(equalTo: view.widthAnchor),
        playerVC.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
    ]

    private var playerVC = PlayerViewController()
    private var userViewModel: UserViewModel!
    
    lazy var playListVc = createTabBar(PlaylistTableViewController.self , title: "Playlist", imageName: "folder.fill") {
        $0.delegate = self
    }
    
    lazy var searchVC = createTabBar(SearchViewController.self, title: "Search", imageName: "magnifyingglass") {
        $0.delegate = self
    }
    
    lazy var likedMoments = createTabBar(LikedMomentsViewController.self , title: "Liked", imageName: "heart.fill") {
        $0.delegate = self
    }
    
    lazy var settingsVC = createTabBar(SettingsTableViewController.self, title: "Settings", imageName: "gear") { [weak self] vc in
        guard let self = self else { return }
        vc.setUser((self.userViewModel) )
        vc.delegate = self
    }
    
    func setUserViewModel(_ userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
    }
    
    lazy var imageView: UIImageView =  {
        $0.image = UIImage(named: "decree")
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView())
    
    private var trailConstraint: NSLayoutConstraint?
    private var leadConstraint: NSLayoutConstraint?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        addPlayer()
        configureImageDarkMode()
        downloadService.downloadsSession = downloadsSession
    }
}

//MARK: - Private methods
extension TabBarViewController {
    
    private func configureTabBar() {
        viewControllers = [playListVc, searchVC, likedMoments, settingsVC]
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
    
    func addOrRemoveFromFavorite(podcast: Podcast) {

        let viewContext = DataStoreManager.shared.viewContext
        
        if podcast.isFavorite {
            podcast.isFavorite = false
            
            MyToast.create(title: (podcast.trackName ?? "podcast") + "is removed from playlist", .bottom, timeToAppear: 0.2, timerToRemove: 2, for: self.view)
        } else {
            podcast.isFavorite = true
            MyToast.create(title: (podcast.trackName ?? "podcast") + "is added to playlist", .bottom, timeToAppear: 0.2, timerToRemove: 2, for: self.view)
        }
        viewContext.mySave()
        feedbackGenerator()
    }
}

// MARK: - SearchViewControllerDelegate
extension TabBarViewController: SearchViewControllerDelegate {
    func searchViewControllerDidSelectDownLoadImage(_ searchViewController: SearchViewController, podcast: Podcast, indexPath: IndexPath) {
        if podcast.isDownLoad {
            guard let url = podcast.previewUrl.url else { return }
            downloadService.activeDownloads[url]?.task?.cancel()
            downloadService.activeDownloads[url] = nil
            podcast.isDownLoad = false
            try? FileManager.default.removeItem(at: url)
            searchViewController.reloadRows(indexPath: indexPath)
        } else {
            downloadService.startDownload(podcast, indexPath: indexPath)
            podcast.isDownLoad = true
        }
        DataStoreManager.shared.viewContext.mySave()
        feedbackGenerator()
    }
    
    
    func searchViewController(_ searchViewController: SearchViewController, _ podcasts: [Podcast], didSelectIndex: Int) {
        playerVC.view.isHidden = false
        playerVC.play(podcasts: podcasts, at: didSelectIndex)
        searchViewController.playerIsShow()
    }
  
    func podcastCellDidSelectStar(podcast: Podcast) {
        addOrRemoveFromFavorite(podcast: podcast)
    }
}

// MARK: - PlaylistTableViewControllerDelegate
extension TabBarViewController: PlaylistViewControllerDelegate {
    
    func playlistTableViewControllerDidSelectDownLoadButton(_ playlistTableViewController: PlaylistTableViewController, podcast: Podcast) {
        guard let indexPath = playlistTableViewController.getIndexPath(for: podcast) else { return }
        downloadService.startDownload(podcast, indexPath: indexPath)
    }
    
    func playlistTableViewController(_ playlistTableViewController: PlaylistTableViewController, podcasts: [Podcast], didSelectIndex: Int) {
        playerVC.view.isHidden = false
        playerVC.play(podcasts: podcasts, at: didSelectIndex)
        playlistTableViewController.playerIsShow()
    }
}

// MARK: - SettingsTableViewControllerDelegate
extension TabBarViewController: SettingsTableViewControllerDelegate {
    
    func settingsTableViewControllerDarkModeDidSelect(_ settingsTableViewController: SettingsTableViewController) {
        
        self.trailConstraint?.isActive.toggle()
        self.leadConstraint?.isActive.toggle()
         
        UIView.animate(withDuration: 2, delay: 0, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            
            settingsTableViewController.switchDarkMode()
            
            UIView.animate(withDuration: 0.5) {
                self.trailConstraint?.isActive.toggle()
                self.leadConstraint?.isActive.toggle()
                self.view.layoutIfNeeded()
            }
        }
    }
    
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
    func likedMomentViewController(_ likedMomentViewController: LikedMomentsViewController, didSelectMomentAt index: Int) {
        let allLikedMoments: [LikedMoment] = LikedMomentsManager.shared().getLikedMomentsFromUserDefault()
        playerVC.view.isHidden = false
        playerVC.playMomentWith(atIndex: index, from: allLikedMoments)
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
        let podcast = podcastDownload.podcast
        
        DispatchQueue.main.async {
            self.searchVC.updateDisplay(progress: progress, totalSize: totalSize, podcast: podcast)
            self.playListVc.updateDisplay(progress: progress, totalSize: totalSize, podcast: podcast)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager.default
        guard
            let sourceURL = downloadTask.originalRequest?.url,
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return }
        
        let localPath = documentsPath.appendingPathComponent(sourceURL.lastPathComponent)
        
        try? fileManager.removeItem(at: localPath)
        
        do {
            try fileManager.copyItem(at: location, to: localPath)
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        guard let podcastDownload = self.downloadService.activeDownloads[sourceURL] else { return }
        let podcast = podcastDownload.podcast
        let indexPath = podcastDownload.indexPath
        let viewContext = DataStoreManager.shared.viewContext
        downloadService.activeDownloads[sourceURL] = nil
        
        DispatchQueue.main.async {
            podcast.isDownLoad = true
            viewContext.mySave()
            self.searchVC.reloadRows(indexPath: indexPath)
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
