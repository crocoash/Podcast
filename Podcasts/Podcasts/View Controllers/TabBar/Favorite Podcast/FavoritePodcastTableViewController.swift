//
//  PlaylistTableViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit
import CoreData

protocol FavoritePodcastViewControllerDelegate : AnyObject {
    
    func favoritePodcastTableViewController(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, playlist: [Podcast], podcast: Podcast)
    func favoritePodcastTableViewControllerDidSelectDownLoadImage(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, podcast: Podcast)
    func favoritePodcastTableViewControllerDidSelectStar(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, podcast: Podcast)
    func favoritePodcastTableViewControllerDidSelectCell(_ favoritePodcastTableViewController: FavoritePodcastTableViewController, podcast: Podcast)
//    func favoritePodcastTableViewControllerDidRefreshTableView(_favoritePodcastTableViewController: FavoritePodcastTableViewController)
}

protocol FavoritePodcastViewControllerProtocol {
    var favoritePodcastIsEmpty: Bool { get }
    var favoritePodcastFRC: NSFetchedResultsController<FavoritePodcast> { get }
    func getPodcast(by indexPath: IndexPath) -> Podcast
    func getIndexPath(id: NSNumber?) -> IndexPath?
    func removeAllFavorites()
    func updateFavoritePodcastFromFireBase(completion: ((Result<[FavoritePodcast]>) -> Void)?)
}

class FavoritePodcastTableViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyTableImageView: UIImageView!
    @IBOutlet private weak var removeAllButton: UIBarButtonItem!
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    weak var delegate: FavoritePodcastViewControllerDelegate?
    private var tableViewBottomConstraintConstant = CGFloat(0)
    private let refreshControl = UIRefreshControl()
    
    private var playerIsSHidden = true {
        didSet {
            tableViewBottomConstraintConstant = playerIsSHidden ? 0 : 50
            tableViewBottomConstraint?.constant = tableViewBottomConstraintConstant
        }
    }
    
    //MARK: Public Methods
    func updateConstraintForTableView(playerIsPresent value: Bool) {
        playerIsSHidden = !value
    }
    
    /// Download
    func updateDownloadInformation(progress: Float, totalSize: String, podcast: Podcast) {
        guard let favoritePodcast = podcast.getFavoritePodcast,
              let indexPath = favoritePodcast.getIndexPath,
              let podcastCell = tableView?.cellForRow(at: indexPath) as? PodcastCell
        else { return }
        
        podcastCell.updateDownloadInformation(progress: progress, totalSize: totalSize)
    }
    
    func endDownloading(podcast: Podcast) {
        guard let indexPath = FavoritePodcast.getIndexPath(id: podcast.id) else { return }
        if let cell = tableView.cellForRow(at: indexPath) as? PodcastCell {
            cell.endDownloading()
        }
    }
    
    //MARK: View Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showEmptyImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        tableViewBottomConstraint.constant = tableViewBottomConstraintConstant
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FavoritePodcast.fetchResultController.delegate = self
    }
    
    //MARK: Actions
    @IBAction func removeAllAction(_ sender: UIButton) {
        FavoritePodcast.removeAll()
    }
    
    func tapCell(at indexPath: IndexPath) {
        let podcast = getPodcast(by: indexPath)
        delegate?.favoritePodcastTableViewControllerDidSelectCell(self, podcast: podcast)
    }
    
    @objc func refreshTableView() {
        FavoritePodcast.updateFromFireBase { [weak self] result in
            switch result {
            case .failure(error: let error) :
                error.showAlert(vc: self) {
                    self?.refreshControl.endRefreshing()
                    self?.refreshControl.isHidden = true
                }
            case .success(result: _) :
                self?.refreshControl.endRefreshing()
                self?.refreshControl.isHidden = true
            }
        }
    }
}

//MARK: - Private methods
extension FavoritePodcastTableViewController {
    
    private func configureUI() {
        navigationItem.title = "PlayList"
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.rowHeight = 100
        tableView.allowsSelection = true
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func showEmptyImage() {
        let favoritePodcastsIsEmpty = FavoritePodcast.allObjectsFromCoreData.isEmpty
        tableView.isHidden = favoritePodcastsIsEmpty
        emptyTableImageView.isHidden = !favoritePodcastsIsEmpty
        removeAllButton.isEnabled = !favoritePodcastsIsEmpty
    }
    
    private func getPodcast(_ cell: UITableViewCell) -> Podcast? {
        guard let indexPath = tableView.indexPath(for: cell) else { return nil }
        return FavoritePodcast.getObject(by: indexPath).podcast
    }
    
    private func getPodcast(by indexPath: IndexPath) -> Podcast {
        return FavoritePodcast.getObject(by: indexPath).podcast
    }
}

// MARK: - UITableViewDataSource
extension FavoritePodcastTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let podcast = getPodcast(by: indexPath)
            delegate?.favoritePodcastTableViewControllerDidSelectStar(self, podcast: podcast)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoritePodcast.fetchResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return FavoritePodcast.fetchResultController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
        let podcast = getPodcast(by: indexPath)
        cell.configureCell(self,with: podcast)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension FavoritePodcastTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapCell(at: indexPath)
    }
}

//MARK: - PodcastCellDelegate
extension FavoritePodcastTableViewController: PodcastCellDelegate {
    
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell) {
        guard let podcast = getPodcast(podcastCell) else { return }
        delegate?.favoritePodcastTableViewControllerDidSelectStar(self, podcast: podcast)
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell) {
        guard let podcast = getPodcast(podcastCell) else { return }
        delegate?.favoritePodcastTableViewControllerDidSelectDownLoadImage(self, podcast: podcast)
    }
    
    func podcastCellDidTouchPlayButton(_ podcastCell: PodcastCell) {
        
    }
    
    func podcastCellDidTouchStopButton(_ podcastCell: PodcastCell) {
        
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension FavoritePodcastTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete :
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .left)
            let title = "podcast is removed from playlist"
            addToast(title: title, (playerIsSHidden ? .bottomWithTabBar : .bottomWithPlayerAndTabBar))
        case .insert :
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .left)
                let favoritePodcast = FavoritePodcast.fetchResultController.object(at: newIndexPath)
                let name = favoritePodcast.podcast.trackName ?? ""
                let title = "\(name) podcast is added to playlist"
                addToast(title: title, (playerIsSHidden ? .bottom : .bottomWithPlayer))
            }
        case .move :
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .left)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .left)
            }
        case .update :
            if let indexPath = indexPath {
                let podcast = getPodcast(by: indexPath)
                if let cell = tableView.cellForRow(at: indexPath) as? PodcastCell {
                    cell.configureCell(nil, with: podcast)
                }
            }
        default : break
        }
        showEmptyImage()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
}
