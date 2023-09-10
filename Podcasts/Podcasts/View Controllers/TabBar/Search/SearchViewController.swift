//
//  SearchViewController.swift
//  Podcasts
//
//  Created by mac on 25.10.2021.
//

import UIKit
import CoreData
import SwiftUI

//MARK: - Delegate
protocol SearchViewControllerDelegate: AnyObject {
//    func searchViewController                      (_ searchViewController: SearchViewController,_ playlist: [TrackProtocol], track: TrackProtocol)
//    func searchViewControllerDidSelectDownLoadImage(_ searchViewController: SearchViewController, entity: DownloadInputType, completion: @escaping () -> Void)
//    func searchViewControllerDidSelectFavouriteStar (_ searchViewController: SearchViewController, podcast: Podcast)
    func searchViewControllerDidSelectCell (_ searchViewController: SearchViewController, podcast: Podcast)
}

typealias PlaylistByNewest  = [(key: String, podcasts: [Podcast])]
typealias PlayListByOldest = PlaylistByNewest
typealias PlayListByGenre = PlaylistByNewest

class SearchViewController : UIViewController, IPerRequest {

    
    
    typealias Arguments = Void
    
    
    private let apiService: ApiServiceInput
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var searchCollectionView: SearchCollectionView!
    @IBOutlet private weak var cancelLabel: UILabel!
    @IBOutlet private weak var searchSegmentalControl: UISegmentedControl!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var emptyTableImageView: UIImageView!
    
    private var tableViewBottomConstraintConstant = CGFloat(0)
    private let refreshControl = UIRefreshControl()

    private var alert = Alert()
    
    private var podcasts = Array<Podcast>() {
        didSet {
            self.playList = podcasts.sortPodcastsByGenre
        }
    }
    
    private var playList: [(key: String, rows: [Podcast])] = []
   
    private var authors = Array<Author>()
    
    weak var delegate: SearchViewControllerDelegate?
    
    //MARK: - Methods
    private var playerIsSHidden = true {
        didSet {
            tableViewBottomConstraintConstant = playerIsSHidden ? 0 : 50
            tableViewBottomConstraint?.constant = tableViewBottomConstraintConstant
        }
    }
    
    //MARK: - Public Methods
    func updateConstraintForTableView(playerIsPresent value: Bool) {
        playerIsSHidden = !value
    }
    
    private var isPodcast: Bool { searchSegmentalControl.selectedSegmentIndex == 0 }
    
    //MARK: init
    init?<T: SearchViewControllerDelegate>(coder: NSCoder,
                                           _ vc : T,
                                           apiService: ApiServiceInput) {
        self.delegate = vc
        self.apiService = apiService
        
        super.init(coder: coder)
    }
    
    required convenience init(container: IContainer, args: Void) {
        self.init(coder: <#T##NSCoder#>)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        tableViewBottomConstraint.constant = tableViewBottomConstraintConstant
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        cancelSearchAction()
        feedbackGenerator()
    }
    
    //MARK: - Actions
    func tapCell(atIndexPath indexPath: IndexPath) {
        let podcast = playList[indexPath]
        delegate?.searchViewControllerDidSelectCell(self, podcast: podcast)
    }
    
    @objc func cancelSearch(sender: UITapGestureRecognizer) {
        cancelSearchAction()
    }
    
    @objc func refresh() {
        getData()
        refreshControl.endRefreshing()
    }
    
    @objc func changeTypeOfSearch(sender: UISegmentedControl) {
        getData()
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
        configureCancelLabel()
        configureSegmentalControl()
        configureAlert()
//        configureActivityIndicator()
    }
    
    private func configureGesture() {
//        addMyGestureRecognizer(self, type: .swipe(directions: [.left,.right]), #selector(handlerSwipe))
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
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
    
//    private func configureActivityIndicator() {
//        activityIndicator.isHidden = true
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.style = .large
//        activityIndicator.center = view.center
//        view.addSubview(activityIndicator)
//    }
    
    private func cancelSearchAction() {
        searchBar.text?.removeAll()
        podcasts.removeAll()
        showEmptyImage()
    }
    
    private func showEmptyImage() {
        let podcastsIsEmpty = podcasts.isEmpty
        let authorsIsEmpty = authors.isEmpty
        let selectedFirstSegmentalControl = searchSegmentalControl?.selectedSegmentIndex == 0
        let selectedSecondSegmentalControl = searchSegmentalControl?.selectedSegmentIndex == 1
        
        if selectedFirstSegmentalControl && podcastsIsEmpty || selectedSecondSegmentalControl && authorsIsEmpty {
            searchCollectionView.isHidden = true
            emptyTableImageView.isHidden = false
        }
        
        if selectedFirstSegmentalControl && !podcastsIsEmpty || selectedSecondSegmentalControl && !authorsIsEmpty {
            searchCollectionView.isHidden = false
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
            self.alert.create(vc: self, title: "Ooops nothing search", withTimeIntervalToDismiss: 2)
        }
        self.showEmptyImage()
        searchCollectionView.reloadData()
    }
    
    private func getData() {
        searchCollectionView.setContentOffset(.zero, animated: true)
        guard let request = searchBar.text?.conform, !request.isEmpty else { showEmptyImage(); return }
        view.showActivityIndicator()
        if searchSegmentalControl.selectedSegmentIndex == 0 {
            getPodcasts(request: DynamicLinkManager.podcastSearch(request).url)
        } else {
            getAuthors(request: DynamicLinkManager.authors(request).url)
        }
    }
    
    private func getPodcasts(request: String) {
        apiService.getData(for: request) { [weak self] (result: Result<PodcastData>) in
            switch result {
            case .success(result: let podcastData) :
                guard let podcasts = podcastData.results.allObjects as? [Podcast] else { return }
                
                self?.processResults(result: podcasts) {
                    self?.podcasts = $0
                }
            case .failure(error: let error) :
                error.showAlert(vc: self)
            }
            self?.view.hideActivityIndicator()
        }
    }
    
    private func getAuthors(request: String) {
        apiService.getData(for: request) { [weak self] (result: Result<AuthorData>) in
            switch result {
            case .success(result: let authorData) :
                let authors = authorData.results?.allObjects as? [Author]
                self?.processResults(result: authors) {
                    self?.authors = $0
                }
            case .failure(error: let error) :
                error.showAlert(vc: self)
            }
//            self?.activityIndicator.stopAnimating()
            self?.view.hideActivityIndicator()
        }
    }
    
//    private func updateCell(for podcast: Podcast) {
//        if isPodcast, let index = podcasts.firstIndex(matching: podcast) {
//            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .bottom)
//        }
//    }
}

//// MARK: - TableView Data Source
//extension SearchViewController: UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return isPodcast ? podcasts.count : authors.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return isPodcast ? configurePodcastCell(indexPath, for: tableView) : configureAuthorCell(indexPath, for: tableView)
//    }
//}


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

//MARK: - SearchCollectionViewDelegate
extension SearchViewController: SearchCollectionViewDelegate {
    func searchCollectionView(_ searchCollectionView: SearchCollectionView, didTapAtIndexPath indexPath: IndexPath) {
        tapCell(atIndexPath: indexPath)
    }
}

//MARK: - SearchCollectionViewDataSource
extension SearchViewController: SearchCollectionViewDataSource {
    
    func searchCollectionViewNumbersOfSections(_ searchCollectionView: SearchCollectionView) -> Int {
        return playList.count
    }
    
    func searchCollectionView(_ searchCollectionView: SearchCollectionView, nameOfSectionForIndex index: Int) -> String {
        return playList[index].key
    }
    
    func searchCollectionView(_ searchCollectionView: SearchCollectionView, numbersOfRowsInSection index: Int) -> Int {
        return playList[index].rows.count
    }
    
    func searchCollectionView(_ searchCollectionView: SearchCollectionView, rowForIndexPath indexPath: IndexPath) -> SearchCollectionView.Row {
        let podcast = playList[indexPath]
        let row = SearchCollectionView.Row(podcast: podcast)
        return row
    }
}
