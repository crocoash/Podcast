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
    func searchViewController                      (_ searchViewController: SearchViewController,_ podcasts: [Podcast], didSelectIndex: Int)
    func searchViewControllerDidSelectDownLoadImage(_ searchViewController: SearchViewController, podcast: Podcast)
    func searchViewControllerDidSelectFavoriteStar (_ searchViewController: SearchViewController, podcast: Podcast)
}

class SearchViewController : UIViewController {
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var cancelLabel: UILabel!
    @IBOutlet private weak var searchSegmentalControl: UISegmentedControl!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var emptyTableImageView: UIImageView!
    
    private var tableViewBottomConstraintContstnt: CGFloat = 0
    private let refreshControll = UIRefreshControl()

    private let activityIndicator = UIActivityIndicatorView()
    private var alert             = Alert()
    private var podcasts          = Array<Podcast>()
    private var authors           = Array<Author>()
    
    weak var delegate: SearchViewControllerDelegate?
    
    //MARK: - Methods
    
    private var playerIsSHidden = true {
        didSet {
            tableViewBottomConstraintContstnt = playerIsSHidden ? 0 : 50
            tableViewBottomConstraint?.constant = tableViewBottomConstraintContstnt
        }
    }
    
    //MARK: - Methods
    func playerIsHidden(_ bool: Bool) {
        playerIsSHidden = bool
    }
    
    func updateDisplay(progress: Float, totalSize: String, id: NSNumber) {
        guard let index = podcasts.firstIndex(matching: id) else { return }
        
        if let podcastCell = self.tableView?.cellForRow(at: IndexPath(row: index, section: 0)) as? PodcastCell {
            podcastCell.updateDisplay(progress: progress, totalSize: totalSize)
        }
    }
    
    func reloadData(indexPath: [IndexPath]) {
        tableView?.reloadRows(at: indexPath, with: .none)
        showEmptyImage()
    }
    
    private var isPodcast: Bool { searchSegmentalControl.selectedSegmentIndex == 0 }
    
    // MARK: - View Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showEmptyImage()
        if podcasts.isEmpty { searchBar.becomeFirstResponder() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureGesture()
        showEmptyImage()
        tableViewBottomConstraint.constant = tableViewBottomConstraintContstnt
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
        getData()
        refreshControll.endRefreshing()
    }
    
    @objc func changeTypeOfSearch(sender: UISegmentedControl) {
        getData()
    }
    
    @objc func handlerTapAuthorCell(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UITableViewCell,
              let indexPath = tableView.indexPath(for: view) else { return }
        
        searchSegmentalControl.selectedSegmentIndex = 0
        getData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func handlerTapPodcastCell(sender : UITapGestureRecognizer) {
        guard let view = sender.view as? UITableViewCell,
              let indexPath = tableView.indexPath(for: view) else { return }
        
        let podcast = podcasts[indexPath.row]
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
        getData()
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
        AuthorDocument.shared.searchFRC.delegate = self
    }
    
    private func configureTableView() {
        tableView.register(PodcastCell.self)
        tableView.register(PodcastByAuthorCell.self)
        tableView.rowHeight = 100
        refreshControll.tintColor = .yellow
        tableView.refreshControl = refreshControll
        
    }
    
    private func configureGesture() {
        view.addMyGestureRecognizer(self, type: .swipe(directions: [.left,.right]), #selector(handlerSwipe))
        refreshControll.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    private func configureCancelLabel() {
        cancelLabel.addMyGestureRecognizer(self, type: .tap(), #selector(cancelSearch))
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
    
    private func cancelSearchAction() {
        searchBar.text?.removeAll()
        podcasts.removeAll()
        showEmptyImage()
    }
    
    private func showEmptyImage() {
        let podcastsIsEmpty = podcasts.isEmpty
        let authorsIsEmpty = authors.isEmpty
        
        if (searchSegmentalControl?.selectedSegmentIndex == 0 && podcastsIsEmpty) ||
            (searchSegmentalControl?.selectedSegmentIndex == 1 && authorsIsEmpty) {
            tableView.isHidden = true
            emptyTableImageView.isHidden = false
        }
        
        if (searchSegmentalControl?.selectedSegmentIndex == 0 && !podcastsIsEmpty ||
            (searchSegmentalControl?.selectedSegmentIndex == 1 && !authorsIsEmpty)) {
            tableView.isHidden = false
            emptyTableImageView.isHidden = true
        }
    }
    
    private func feedbackGenerator() {
        let feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
}

//MARK: - Private methods
extension SearchViewController {
    
    private func processResults<T>(result: [T]?, completion: (([T]) -> Void)? = nil) {
        if let result = result, !result.isEmpty {
            completion?(result)
        } else {
            self.alert.create(title: "Ooops nothing search", withTimeIntervalToDismiss: 2)
        }
        self.showEmptyImage()
        tableView.reloadData()
    }
    
    private func getData() {
        tableView.setContentOffset(.zero, animated: true)
        guard let request = searchBar.text?.conform, !request.isEmpty else { showEmptyImage(); return }
        activityIndicator.startAnimating()
        if searchSegmentalControl.selectedSegmentIndex == 0 {
            getPodcasts(request: UrlRequest1.podcastEpisode(request).url)
        } else {
            getAuthors(request: UrlRequest1.authors(request).url)
        }
    }
    
    private func getPodcasts(request: String) {
        ApiService.getData(for: request) { [weak self] (result: Result<PodcastData>) in
            switch result {
            case .success(result: let podcastData) :
                guard let podcasts = podcastData.results.allObjects as? [Podcast] else { return }
                
                self?.processResults(result: podcasts) {
                    self?.podcasts = $0
                }
            case .failure(error: let error) :
                error.showAlert(vc: self)
            }
            self?.activityIndicator.stopAnimating()
        }
    }
    
    private func getAuthors(request: String) {
        ApiService.getData(for: request) { [weak self] (result: Result<AuthorData>) in
            switch result {
            case .success(result: let authorData) :
                let authors = authorData.results.allObjects as? [Author]
                self?.processResults(result: authors) {
                    self?.authors = $0
                }
            case .failure(error: let error) :
                error.showAlert(vc: self)
            }
            self?.activityIndicator.stopAnimating()
        }
    }
    
    private func configurePodcastCell(_ indexPath: IndexPath,for tableView: UITableView) -> UITableViewCell {
        let podcast = podcasts[indexPath.row]
        let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
        
        DownloadService().resumeDownload(podcast)
        cell.delegate = self
        cell.configureCell(with: podcast)
        cell.addMyGestureRecognizer(self, type: .tap(), #selector(handlerTapPodcastCell))
        
        return cell
    }
    
    private func configureAuthorCell(_ indexPath: IndexPath,for tableView: UITableView) -> UITableViewCell {
        let author = authors[indexPath.row]
        let cell = tableView.getCell(cell: PodcastByAuthorCell.self, indexPath: indexPath)
        cell.configureCell(with: author)
        cell.addMyGestureRecognizer(self, type: .tap(), #selector(handlerTapAuthorCell))
       
        return cell
    }
}

// MARK: - TableView Data Source
extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isPodcast ? podcasts.count : authors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return isPodcast ? configurePodcastCell(indexPath, for: tableView) : configureAuthorCell(indexPath, for: tableView)
    }

}

// MARK: - PodcastCellDelegate
extension SearchViewController: PodcastCellDelegate {
    
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell, podcast: Podcast) {
        searchBar.resignFirstResponder()
        guard let indexPath = tableView.indexPath(for: podcastCell) else { return }
        delegate?.searchViewControllerDidSelectFavoriteStar(self, podcast: podcast)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell, podcast: Podcast) {
        searchBar.resignFirstResponder()
        delegate?.searchViewControllerDidSelectDownLoadImage(self, podcast: podcast)
        guard let indexPath = tableView.indexPath(for: podcastCell) else { return }
        tableView.reloadRows(at: [indexPath], with: .top)
    }
}


//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else { return }
        getData()
        view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        addMyGestureRecognizer(view, type: .tap(), #selector(UIView.endEditing(_:)))
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getData()
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


//MARK: - DetailViewControllerDelegate
extension SearchViewController: DetailViewControllerDelegate {
    
    func detailViewController(_ detailViewController: DetailViewController, playButtonDidTouchFor podcastIndex: Int) {
        delegate?.searchViewController(self, podcasts, didSelectIndex: podcastIndex)
    }
    
    func detailViewController(_ detailViewController: DetailViewController, addToFavoriteButtonDidTouchFor selectedPodcast: Podcast) {
        delegate?.searchViewControllerDidSelectFavoriteStar(self, podcast: selectedPodcast)
    }
    
    func detailViewController(_ detailViewController: DetailViewController, removeFromFavoriteButtonDidTouchFor selectedPodcast: Podcast) {
        delegate?.searchViewControllerDidSelectFavoriteStar(self, podcast: selectedPodcast)
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension SearchViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    }
}
