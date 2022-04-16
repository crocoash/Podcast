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
    func searchViewControllerDidSelectDownLoadImage(_ searchViewController: SearchViewController, podcast: Podcast, indexPath: IndexPath)
    func podcastCellDidSelectStar(podcast: Podcast)
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
    
    private let viewContext = DataStoreManager.shared.viewContext
    
    private var podcasts: [Podcast] { searchPodcastFetchResultController.fetchedObjects ?? [] }
    private var authors: [Author] { Author.searchAuthors }
    
    lazy var searchPodcastFetchResultController: NSFetchedResultsController<Podcast> = {
        let fetchRequest: NSFetchRequest<Podcast> = Podcast.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Podcast.trackName), ascending: true)]
        
        fetchRequest.predicate = NSPredicate(format: "isSearched = true")
        
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try! fetchResultController.performFetch()
        return fetchResultController
    }()
    
    lazy var searchAuthorFetchResultController: NSFetchedResultsController<Author> = {
        let fetchRequest: NSFetchRequest<Author> = Author.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Author.artistID), ascending: true)]
        
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try! fetchResultController.performFetch()
        return fetchResultController
    }()
    
    func playerIsShow() { playerOffSetConstraint.constant = 300  }
    
    func updateDisplay(progress: Float, totalSize: String, podcast: Podcast) {
        guard let indexPath = searchPodcastFetchResultController.indexPath(forObject: podcast) else { return }
        if let podcastCell = self.podcastTableView?.cellForRow(at: indexPath) as? PodcastCell {
            podcastCell.updateDisplay(progress: progress, totalSize: totalSize)
        }
    }
    
    func reloadRows(indexPath: IndexPath) {
        self.podcastTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    private var isPodcast: Bool { searchSegmentalControl.selectedSegmentIndex == 0 }
    
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
        getData(with: searchBar.text)
    }
    
    @objc func handlerTapAuthorCell(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UITableViewCell,
              let indexPath = podcastTableView.indexPath(for: view),
              let request = searchAuthorFetchResultController.object(at: indexPath).artistName else { return }
        
        searchSegmentalControl.selectedSegmentIndex = 0
        getData(with: request)
        podcastTableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func handlerTapPodcastCell(sender : UITapGestureRecognizer) {
        guard let view = sender.view as? UITableViewCell,
              let indexPath = podcastTableView.indexPath(for: view) else { return }
        
        let podcast = searchPodcastFetchResultController.object(at: indexPath)
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
        getData(with: searchBar.text)
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
        searchPodcastFetchResultController.delegate = self
    }
    
    private func configureTableView() {
        podcastTableView.register(PodcastCell.self)
        podcastTableView.register(PodcastByAuthorCell.self)
        podcastTableView.rowHeight = 100
        podcastTableView.addSubview(refreshControll)
    }
    
    private func configureGesture() {
        view.addMyGestureRecognizer(self, type: .swipe(directions: [.left,.right]), selector: #selector(handlerSwipe))
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
    
    private func configureActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }
    
    private func cancelSearchAction() {
        AuthorData.cancellSearch()
        PodcastData.cancellSearch()
        podcastTableView.reloadData()
        showEmptyImage()
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
            podcastTableView.reloadData()
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
    private func processResults<T>(data: [T]?) {
        activityIndicator.stopAnimating()
        
        if let data = data, !data.isEmpty {
        } else {
            self.alert.create(title: "Ooops nothing search", withTimeIntervalToDismiss: 2)
        }
        self.showEmptyImage()
    }
    
    private func getData(with request: String?) {
        guard let request = request?.conform, !request.isEmpty else { showEmptyImage(); return }
        activityIndicator.startAnimating()
        
        if searchSegmentalControl.selectedSegmentIndex == 0 {
            ApiService.getData(for: UrlRequest1.getStringUrl(.podcast(request))) { [weak self] (info: PodcastData?) in
                guard let self = self else { return }
                let results = info?.results.compactMap { $0 as? Podcast }
                self.processResults(data: results)
            }
        } else {
            ApiService.getData(for: UrlRequest1.getStringUrl(.authors(request))) { [weak self] (info: AuthorData?) in
                guard let self = self else { return }
                let results = info?.results.compactMap { $0 as? Author }
                self.processResults(data: results)
            }
        }
    }
}

// MARK: - PodcastCellDelegate
extension SearchViewController: PodcastCellDelegate {
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell, podcast: Podcast) {
        guard let indexPath = podcastTableView.indexPath(for: podcastCell) else { return }
        delegate?.podcastCellDidSelectStar(podcast: podcast)
        podcastTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell, podcast: Podcast) {
        guard let indexPath = podcastTableView.indexPath(for: podcastCell) else { return }
        delegate?.searchViewControllerDidSelectDownLoadImage(self, podcast: podcast, indexPath: indexPath)
    }
}

// MARK: - TableView Data Source
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPodcast {
            return searchPodcastFetchResultController.sections?[section].numberOfObjects ?? 0
        } else {
            return authors.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return isPodcast ? configurePodcastCell(indexPath, for: tableView) : configureAuthorCell(indexPath, for: tableView)
    }
    
    private func configurePodcastCell(_ indexPath: IndexPath,for tableView: UITableView) -> UITableViewCell {
        let podcast = searchPodcastFetchResultController.object(at: indexPath)
        let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
        
        cell.delegate = self
        cell.configureCell(with: podcast)
        cell.addMyGestureRecognizer(self, type: .tap(), selector: #selector(handlerTapPodcastCell))
        
        return cell
    }
    
    private func configureAuthorCell(_ indexPath: IndexPath,for tableView: UITableView) -> UITableViewCell {
        let author = searchAuthorFetchResultController.object(at: indexPath)
        let cell = tableView.getCell(cell: PodcastByAuthorCell.self, indexPath: indexPath)
        cell.configureCell(with: author, indexPath)
        cell.addMyGestureRecognizer(self, type: .tap(), selector: #selector(handlerTapAuthorCell))
        
        return cell
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else { return }
        getData(with: searchBar.text)
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


//MARK: - DetailViewControllerDelegate
extension SearchViewController: DetailViewControllerDelegate {
    func detailViewController(_ detailViewController: DetailViewController, playButtonDidTouchFor podcastIndex: Int) {
        delegate?.searchViewController(self, podcasts, didSelectIndex: podcastIndex)
    }
    
    func detailViewController(_ detailViewController: DetailViewController, addToFavoriteButtonDidTouchFor selectedPodcast: Podcast) {
        delegate?.podcastCellDidSelectStar(podcast: selectedPodcast)
//        podcastTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func detailViewController(_ detailViewController: DetailViewController, removeFromFavoriteButtonDidTouchFor selectedPodcast: Podcast) {
        delegate?.podcastCellDidSelectStar(podcast: selectedPodcast)
//        podcastTableView.reloadRows(at: [indexPath], with: .none)
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension SearchViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    }
}
