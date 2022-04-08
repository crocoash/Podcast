//
//  SearchViewController.swift
//  Podcasts
//
//  Created by mac on 25.10.2021.
//

import UIKit
import CoreData
import SwiftUI

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ searchViewController: SearchViewController,_ podcasts: [Podcast], didSelectIndex: Int)
}

class SearchViewController : UIViewController {
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var podcastTableView: UITableView!
    @IBOutlet private weak var cancelLabel: UILabel!
    @IBOutlet private weak var searchSegmentalControl: UISegmentedControl!
    @IBOutlet private weak var playerOffSetConstraint: NSLayoutConstraint!
    @IBOutlet private weak var emptyTableImageView: UIImageView!
    
    let refreshControll = UIRefreshControl()
    
    private let activityIndicator = UIActivityIndicatorView()
    private var alert = Alert()
   
    weak var delegate: SearchViewControllerDelegate?

    let viewContext = DataStoreManager.shared.viewContext
    
    private var podcasts: [Podcast] { Podcast.searchPodcasts }
    private var authors: [Author] { Author.searchAuthors }
    
    let searchPodcastFetchResultController = DataStoreManager.shared.searchPodcastFetchResultController
    
    func playerIsShow() {
        playerOffSetConstraint.constant = 300
    }
    
    private var searchText = "" {
        didSet {
            getData(with: searchText.conform)
//            searchBar.text = searchText
        }
    }
    
    private var isPodcast: Bool { searchSegmentalControl.selectedSegmentIndex == 0 }
    private let downloadService = DownloadService()
    
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "BackGroundSession")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    // MARK: - View Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        podcastTableView.reloadData()
        if podcasts.isEmpty { searchBar.becomeFirstResponder() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureGesture()
        showEmptyImage()
        downloadService.downloadsSession = downloadsSession
        searchPodcastFetchResultController.delegate = self
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        cancelSearchAction()
        feedbackGenerator()
    }
    
    //MARK: - Actions
    @objc func cancelSearch(sender: UITapGestureRecognizer) {
        cancelSearchAction()
    }
    
    @objc func refresh() {
        podcastTableView.reloadData()
        refreshControll.endRefreshing()
    }
    
    @objc func changeTypeOfSearch(sender: UISegmentedControl) {
        if !searchText.isEmpty { getData(with: searchText) }
        podcastTableView.reloadData()
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
        

        let podcast = getPodcast(for: indexPath)
        let detailViewController = DetailViewController.initVC
        
        detailViewController.delegate = self
        detailViewController.setUp(index: indexPath.row, podcast: podcast)
        detailViewController.title = "Additional info"
        detailViewController.transitioningDelegate = self
        detailViewController.modalPresentationStyle = .custom
        
        present(detailViewController,animated: true)
    }
    
    @objc func handlerSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left: searchSegmentalControl.selectedSegmentIndex += 1
        case .right: searchSegmentalControl.selectedSegmentIndex -= 1
        default: break
        }
        
        if !searchText.isEmpty { getData(with: searchText) }
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
        podcastTableView.addSubview(refreshControll)
    }
    
    private func configureGesture() {
        view.addMyGestureRecognizer(self, type: .swipe(directions: [.left, .right]), selector: #selector(handlerSwipe))
        podcastTableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .editingChanged)
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
    
    private func getPodcast(for indexPath: IndexPath) -> Podcast {
        return Podcast.getSearchPodcast(for: indexPath)
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
            let podcast = getPodcast(for: indexPath)
            
            if Podcast.podcastIsInPlaylist(podcast: podcast) {
                Podcast.removeFromFavorites(podcast: podcast)
                MyToast.create(title: (podcasts[indexPath.row].trackName ?? "podcast") + "is removed from playlist", .bottom, timeToAppear: 0.2, timerToRemove: 2, for: self.view)
            } else {
                Podcast.addToFavorites(podcast: podcast)
                MyToast.create(title: (podcasts[indexPath.row].trackName ?? "podcast") + "is added to playlist", .bottom, timeToAppear: 0.2, timerToRemove: 2, for: self.view)
            }
            downloadService.startDownload(podcasts[indexPath.row], index: indexPath.row)
            podcastTableView.reloadRows(at: [indexPath], with: .none)
            feedbackGenerator()
        }
    }
    
    private func cancelSearchAction() {
        searchText = ""
        Author.removeAll()
        Podcast.removeAll()
        AuthorData.remove(viewContext: viewContext)
        
        podcastTableView.reloadData()
        showEmptyImage()
        searchSegmentalControl.selectedSegmentIndex = 0
    }
    
    private func showEmptyImage() {
        if (searchSegmentalControl.selectedSegmentIndex == 0 && podcasts.isEmpty) ||
            (searchSegmentalControl.selectedSegmentIndex == 1 && authors.isEmpty) {
            podcastTableView.isHidden = true
            emptyTableImageView.isHidden = false
        }
        if (searchSegmentalControl.selectedSegmentIndex == 0 && !podcasts.isEmpty) ||
            (searchSegmentalControl.selectedSegmentIndex == 1 && !authors.isEmpty) {
            podcastTableView.isHidden = false
            emptyTableImageView.isHidden = true
        }
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
        self.podcastTableView.reloadData()
        self.showEmptyImage()
    }
    
    private func getData(with request: String) {
        guard !request.isEmpty else { return }
        let request = request.conform
        
        activityIndicator.startAnimating()
        
        if searchSegmentalControl.selectedSegmentIndex == 0 {
            ApiService.getData(for: UrlRequest1.getStringUrl(.podcast(request))) { [weak self] (info: PodcastData?) in
                guard let self = self else { return }
                self.processResults(data: info?.results) { _ in }
            }
        } else {
            ApiService.getData(for: UrlRequest1.getStringUrl(.authors(request))) { [weak self] (info: AuthorData?) in
                guard let self = self else { return }
                let results = info?.results.compactMap { $0 as? Author }
                self.processResults(data: results) { _ in }
            }
        }
    }
}

// MARK: - TableView Data Source
extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPodcast {
            return searchPodcastFetchResultController.sections?[section].numberOfObjects ?? 0
        } else {
            return Author.searchAuthors.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return isPodcast ? configurePodcastCell(indexPath, for: tableView) : configureAuthorCell(indexPath, for: tableView)
    }
    
    private func configurePodcastCell(_ indexPath: IndexPath,for tableView: UITableView) -> UITableViewCell {
        let podcast = getPodcast(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: PodcastCell.identifier) as! PodcastCell
        
        cell.configureCell(with: podcast)
        cell.addMyGestureRecognizer(self, type: .longPressGesture(minimumPressDuration: 0.3), selector: #selector(handlerLongPs))
        cell.addMyGestureRecognizer(self, type: .tap(), selector: #selector(handlerTapPodcastCell))
        
        return cell
    }
    
    private func configureAuthorCell(_ indexPath: IndexPath,for tableView: UITableView) -> UITableViewCell {
        let author = Author.searchAuthors[indexPath.row]
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
        addMyGestureRecognizer(view, type: .tap(), selector: #selector(UIView.endEditing(_:)))
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
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let destinationURL = localFilePath(for: sourceURL)
        
        let fileManager = FileManager.default
        
        try? fileManager.removeItem(at: destinationURL)
        
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            guard let podcast = self.downloadService.activeDownloads[sourceURL] else { return }
            
            Podcast.downloadPodcast(podcast: podcast)
            
            self.podcastTableView.reloadRows(at: [IndexPath(row: podcast.index!.intValue, section: 0)], with: .none)
            self.downloadService.activeDownloads[sourceURL] = nil
        }
    }
    
    func urlSession(_ session                   : URLSession,
                    downloadTask               : URLSessionDownloadTask,
                    didWriteData bytesWritten  : Int64,
                    totalBytesWritten          : Int64,
                    totalBytesExpectedToWrite  : Int64) {
        
        guard let url = downloadTask.originalRequest?.url,
              let podcast = downloadService.activeDownloads[url] else { return }
        
        podcast.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        
        DispatchQueue.main.async {
            if let podcastCell = self.podcastTableView.cellForRow(at: IndexPath(row: podcast.index!.intValue, section: 0)) as? PodcastCell {
                podcastCell.updateDisplay(progress: podcast.progress, totalSize: totalSize)
            }
        }
    }
}

//MARK: - URLSessionDelegate
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

//MARK: - DetailViewControllerDelegate
extension SearchViewController: DetailViewControllerDelegate {
    func detailViewController(_ detailViewController: DetailViewController, playButtonDidTouchFor podcastIndex: Int) {
        delegate?.searchViewController(self, podcasts, didSelectIndex: podcastIndex)
    }
    
    func detailViewController(_ detailViewController: DetailViewController, addButtonDidTouchFor selectedPodcast: Podcast) {
        Podcast.addToFavorites(podcast: selectedPodcast)
        guard let index = podcasts.firstIndex(where: {$0 == selectedPodcast}) else {
            fatalError("No such element in collection while download")
        }
        downloadService.startDownload(selectedPodcast, index: index)
        podcastTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none )
    }
    
    func detailViewController(_ detailViewController: DetailViewController, removeButtonDidTouchFor selectedPodcast: Podcast) {
        Podcast.removeFromFavorites(podcast: selectedPodcast)
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension SearchViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    }
}
