//
//  SearchViewController.swift
//  Podcasts
//
//  Created by mac on 25.10.2021.
//

import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ searchViewController: SearchViewController, play podcasts: [Podcast], at index: Int)
}

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
        downloadService.downloadsSession = downloadsSession
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        podcastTableView.reloadData()
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

//MARK: - objc Methods
extension SearchViewController {
    
    @objc func cancelSearch(sender: UITapGestureRecognizer) {
        searchText = ""
        authors.removeAll()
        podcasts.removeAll()
        searchSegmentalControl.selectedSegmentIndex = 0
    }
    
    @objc func changeTypeOfSearch(sender: UISegmentedControl) {
        if !searchText.isEmpty {
            getPodcasts(by: searchText)
        }
    }
    
    @objc func handlerLongPs(sender: UILongPressGestureRecognizer) {
        MyLongPressGestureRecognizer.createSelector(for: sender) { (cell: PodcastCell) in
            guard let view = sender.view as? PodcastCell else { return }
            let podcast = podcasts[view.indexPath.row]
            
            if podcast.isAddToPlaylist {
                PlaylistDocument.shared.removeFromPlayList(podcast)
            } else {
                PlaylistDocument.shared.addToPlayList(podcast)
                downloadService.startDownload(podcast)
            }
            podcastTableView.reloadRows(at: [cell.indexPath], with: .none)
        }
    }
    
    @objc func handlerTapAuthorCell(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? CustomTableViewCell, let request = authors[view.indexPath.row].artistName else { return }
        
        searchSegmentalControl.selectedSegmentIndex = 0
        searchText = request
        podcastTableView.deselectRow(at: view.indexPath, animated: true)
    }
    
    @objc func handlerTapPodcastCell(sender : UITapGestureRecognizer) {
        guard let view = sender.view as? CustomTableViewCell else { return }
        let podcast = podcasts[view.indexPath.row]
        guard let urlString = podcast.artworkUrl160, let url = URL(string: urlString), let trackName = podcast.trackName, let collectionName = podcast.collectionName, let description = podcast.description else { return }
        let detailViewController = storyboard?.instantiateViewController(identifier: DetailViewController.identifier) as! DetailViewController
        detailViewController.delegate = self

        detailViewController.receivePodcastInfoAndIndex(index: view.indexPath.row, image: url, episode: trackName, collection: collectionName, episodeDescription: description)
        self.navigationController?.pushViewController(detailViewController, animated: true)
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
        
        cell.layoutMargins(inset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        cell.configureCell(with: podcast, indexPath)
        cell.addMyGestureRecognizer(self, type: .longPressGesture(minimumPressDuration: 1), selector: #selector(handlerLongPs))
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

// MARK: - TableView Delegate
extension SearchViewController: UITableViewDelegate {
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
    }
    
    func alertShouldShow(_ alert: Alert, alertController: UIAlertController) {
        present(alertController, animated: true)
    }
}















enum UrlRequest1 {
    case podcast(String)
    case authors(String)
    
    static func getStringUrl(_ type: UrlRequest1) -> String {
        switch type {
        case .podcast(let string):
            return "https://itunes.apple.com/search?term=\(string)&entity=podcastEpisode"
        case .authors(let string):
            return "https://itunes.apple.com/search?term=\(string)&media=podcast&entity=podcastAuthor"
        }
    }
}


protocol CustomTableViewCell: UITableViewCell {
    func configureCell<T>(with type: T,_ indexPath: IndexPath)
    func layoutMargins(inset: UIEdgeInsets)
    var indexPath: IndexPath! { get set }
}

enum URLS: String {
    case api = "http://ip-api.com/json/"
}



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
        delegate?.searchViewController(self, play: podcasts, at: podcastIndex)
    }

}

