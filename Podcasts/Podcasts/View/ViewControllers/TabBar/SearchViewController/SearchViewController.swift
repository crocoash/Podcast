//
//  SearchViewController.swift
//  Podcasts
//
//  Created by mac on 25.10.2021.
//

import UIKit

class SearchViewController : UIViewController {
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var podcastTableView: UITableView!
    @IBOutlet private weak var cancelLabel: UILabel!
    @IBOutlet private weak var searchSegmentalControl: UISegmentedControl!
    
    private let activityIndicator = UIActivityIndicatorView()
    private var alert = Alert()
    
    weak var delegate: SearchViewControllerDelegate?
    
    private var podcasts: [Podcast] = [] {
        didSet {
            podcastTableView.reloadData()
        }
    }
    
    private var authors: [Author] = [] {
        didSet {
            podcastTableView.reloadData()
        }
    }
    
    private var searchText = "" {
        didSet {
            if !searchText.isEmpty { getPodcasts(by: searchText.conform) }
            searchBar.text = searchText
        }
    }
    
    private var isPodcast: Bool { searchSegmentalControl.selectedSegmentIndex == 0 }
    private let downloadService = DownloadService()

    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "BackGroundSession")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureGesture()
        downloadService.downloadsSession = downloadsSession
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        podcastTableView.reloadData()
        if podcasts.isEmpty { searchBar.becomeFirstResponder() }
    }
    
    //MARK: - Actions
    @objc func cancelSearch(sender: UITapGestureRecognizer) {
        cancelSearchAction()
    }
    
    @objc func changeTypeOfSearch(sender: UISegmentedControl) {
        if !searchText.isEmpty { getPodcasts(by: searchText) }
    }
    
    @objc func handlerLongPs(sender: UILongPressGestureRecognizer) {
        longPressGesture(sender)
    }
    
    @objc func handlerTapAuthorCell(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UITableViewCell,
              let indexPath = podcastTableView.indexPath(for: view),
              let request = authors[indexPath.row].artistName else { return }
        
        searchSegmentalControl.selectedSegmentIndex = 0
        searchText = request
        podcastTableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func handlerTapPodcastCell(sender : UITapGestureRecognizer) {
        guard let view = sender.view as? UITableViewCell,
        let indexPath = podcastTableView.indexPath(for: view) else { return }
        
        let index = indexPath.row
        let podcast = podcasts[index]
        
        let detailViewController = storyboard?.instantiateViewController(identifier: DetailViewController.identifier) as! DetailViewController
        
        detailViewController.delegate = self
        detailViewController.setUp(index: index, podcast: podcast)
        
        detailViewController.modalPresentationStyle = .custom
        detailViewController.transitioningDelegate = self
        
        present(detailViewController, animated: true)
    }
    
    @objc func handlerSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            searchSegmentalControl.selectedSegmentIndex += 1
        case .right: searchSegmentalControl.selectedSegmentIndex -= 1
        default: break
        }
        if !searchText.isEmpty { getPodcasts(by: searchText) }
    }
}

//MARK: - Private configure UI Methods
extension SearchViewController {
    
    
    
    private func configureUI() {
        configureTableView()
        configureCancelLabel()
        configureSegmentalControl()
        configureAlert()
        configureActivityIndicator()
    }
    
    private func configureTableView() {
        podcastTableView.register(PodcastCell.self)
        podcastTableView.register(PodcastByAuthorCell.self)
        podcastTableView.rowHeight = 100
    }
    
    private func configureGesture() {
        view.addMyGestureRecognizer(self, type: .swipe(directions: [.left, .right]), selector: #selector(handlerSwipe))
    }
    
    private func configureCancelLabel() {
        cancelLabel.addMyGestureRecognizer(self, type: .tap(), selector: #selector(cancelSearch))
    }
    
    private func configureSegmentalControl() {
        searchSegmentalControl.addTarget(self, action: #selector(changeTypeOfSearch), for: .valueChanged)
    }
    
    private func configureAlert() {
        alert.delegate = self
    }
    
    private func configureActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }
    
    private func feedbackGenerator() {
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
    private func longPressGesture(_ sender: UILongPressGestureRecognizer) {
        MyLongPressGestureRecognizer.createSelector(for: sender) { (cell: PodcastCell) in
            guard let view = sender.view as? PodcastCell,
                  let indexPath = podcastTableView.indexPath(for: view) else { return }
            
            var podcast = podcasts[indexPath.row]
            
            if PlaylistDocument.shared.playList.contains(podcast) {
                PlaylistDocument.shared.removeFromPlayList(podcast)
                MyToast.create(title: (podcast.trackName ?? "podcast") + "is removed to playlist", .bottom, timeToAppear: 0.2, timerToRemove: 2, for: self.view)
            } else {
                podcast.isDownloaded = true
                PlaylistDocument.shared.addToPlayList(podcast)
                MyToast.create(title: (podcast.trackName ?? "podcast") + "is added to playlist", .bottom, timeToAppear: 0.2, timerToRemove: 2, for: self.view)
                downloadService.startDownload(podcast)
            }
            podcastTableView.reloadRows(at: [indexPath], with: .none)            
            
            feedbackGenerator()
        }
    }
    
    private func cancelSearchAction() {
        searchText = ""
        authors.removeAll()
        podcasts.removeAll()
        searchSegmentalControl.selectedSegmentIndex = 0
    }
}

//MARK: - Private methods
extension SearchViewController {
    
    private func processResults<T>(data: [T]?, completion: ([T]) -> Void) {
        activityIndicator.stopAnimating()
        
        if let data = data, !data.isEmpty {
            completion(data)
        } else {
            self.alert.create(title: "Ooops nothing search", withTimeIntervalToDismiss: 2)
        }
    }
    
    private func getPodcasts(by request: String) {
        let request = request.conform
        activityIndicator.startAnimating()
        
        if searchSegmentalControl.selectedSegmentIndex == 0 {
            ApiService.getData(for: UrlRequest1.getStringUrl(.podcast(request))) { [weak self] (info: PodcastData?) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.processResults(data: info?.results, completion: { podcasts in
                        self.podcasts = podcasts
                    })
                }
            }
        } else {
            ApiService.getData(for: UrlRequest1.getStringUrl(.authors(request))) { [weak self] (info: AuthorData?) in
                guard let self = self else { return }
                self.processResults(data: info?.results, completion: { authors in
                    self.authors = authors
                })
            }
        }
    }
}

// MARK: - TableView Data Source
extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isPodcast ? podcasts.count : authors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isPodcast {
            return configurePodcastCell(indexPath, tableView)
        } else {
            return configureAuthorCell(indexPath, tableView)
        }
    }
    
    private func configurePodcastCell(_ indexPath: IndexPath,_ tableView: UITableView) -> UITableViewCell {
        let podcast = podcasts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: PodcastCell.identifier) as! PodcastCell
        
        cell.configureCell(with: podcast)
        cell.addMyGestureRecognizer(self, type: .longPressGesture(minimumPressDuration: 0.3), selector: #selector(handlerLongPs))
        cell.addMyGestureRecognizer(self, type: .tap(), selector: #selector(handlerTapPodcastCell))
        
        return cell
    }
    
    private func configureAuthorCell(_ indexPath: IndexPath,_ tableView: UITableView) -> UITableViewCell {
        let author = authors[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: PodcastByAuthorCell.identifier) as! PodcastByAuthorCell
        
        cell.configureCell(with: author, indexPath)
        cell.addMyGestureRecognizer(self, type: .tap(), selector: #selector(handlerTapAuthorCell))
        
        return cell
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else { return }
        searchText = text
        view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addMyGestureRecognizer(view, type: .tap(), selector: #selector(UIView.endEditing(_:)))
    }
}

// MARK: - Alert Delegate
extension SearchViewController: AlertDelegate {
    
    func alertEndShow(_ alert: Alert) {
        dismiss(animated: true)
        searchBar.becomeFirstResponder()
    }
    
    func alertShouldShow(_ alert: Alert, alertController: UIAlertController) {
        present(alertController, animated: true)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension SearchViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }
}

//MARK: - URLSessionDownloadDelegate
extension SearchViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        
        func localFilePath(for url: URL) -> URL {
            return documentsPath.appendingPathComponent(url.lastPathComponent)
        }
        
        downloadService.activeDownloads[sourceURL] = nil
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let destinationURL = localFilePath(for: sourceURL)
        
        let fileManager = FileManager.default
        
        try? fileManager.removeItem(at: destinationURL)
        
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        //TODO: !!!!!!!!!!
        DispatchQueue.main.async {
            print("podcast download sucsellsfull")
        }
    }
}

extension SearchViewController: URLSessionDelegate {
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

extension SearchViewController: DetailViewControllerDelegate {
    func detailViewController(_ detailViewController: DetailViewController, playButtonDidTouchFor podcastIndex: Int) {
        delegate?.searchViewController(self, podcasts, didSelectIndex: podcastIndex)
    }

}
