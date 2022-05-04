//
//  PlaylistTableViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit
import CoreData

protocol PlaylistViewControllerDelegate : AnyObject {
    
    func playlistTableViewController(_ playlistTableViewController: PlaylistTableViewController, podcasts: [Podcast], didSelectIndex: Int)
    func playlistTableViewControllerDidSelectDownLoadImage(_ playlistTableViewController: PlaylistTableViewController, podcast: Podcast)
    func playlistTableViewControllerDidSelectStar(_ playlistTableViewController: PlaylistTableViewController, podcast: Podcast)
    func playlistTableViewControllerDidRefreshTableView(_ playlistTableViewController: PlaylistTableViewController, completion: @escaping () -> Void)
}

class PlaylistTableViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var playerConstraint: NSLayoutConstraint!
    @IBOutlet private weak var emptyTableImageView: UIImageView!
    @IBOutlet private weak var removeAllButton: UIBarButtonItem!
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    weak var delegate: PlaylistViewControllerDelegate?
    
    private let refreshControll = UIRefreshControl()
    
    //MARK: - Methods
    func playerIsShow() {
        tableViewBottomConstraint.constant = -50
    }
    
    func updateDisplay(progress: Float, totalSize: String, id: NSNumber) {
        let favoritePodcast = FavoriteDocument.shared.favoritePodcastFetchResultController.fetchedObjects
        
        guard let podcast = favoritePodcast?.filter({ $0.podcast.id == id }).first?.podcast,
              let indexPath = FavoriteDocument.shared.getIndexPath(for: podcast),
              let podcastCell = self.tableView?.cellForRow(at: indexPath) as? PodcastCell
        else { return }
        
        podcastCell.updateDisplay(progress: progress, totalSize: totalSize)
    }
    
    func reloadData() {
        showEmptyImage()
        tableView.reloadData()
    }

    // MARK: - View Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showEmptyImage()
        tableView.reloadData()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Actions
    @IBAction func removeAllAction(_ sender: UIButton) {
        FavoriteDocument.shared.removaAllFavorites()
        FirebaseDatabase.shared.savePodcast()
        showEmptyImage()
    }
    
    @objc func tapCell(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UITableViewCell,
              let indexPath = tableView.indexPath(for: view) else { return }
        
        let podcast = FavoriteDocument.shared.getPodcast(for: indexPath)
       
        let vc = DetailViewController.initVC
        vc.delegate = self
        vc.transitioningDelegate = self
        vc.setUp(index: indexPath.row, podcast: podcast)
        vc.modalPresentationStyle = .custom
        
        present(vc, animated: true)
    }
    
    @objc func refreshTableView() {
        delegate?.playlistTableViewControllerDidRefreshTableView(self) { [weak self] in
            self?.refreshControll.endRefreshing()
            self?.refreshControll.isHidden = true
            self?.showEmptyImage()
            self?.tableView.reloadData()
        }
    }
}

//MARK: - Private methods
extension PlaylistTableViewController {
    
    private func configureUI() {
        FavoriteDocument.shared.favoritePodcastFetchResultController.delegate = self
        navigationItem.title = "PlayList"
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.register(PodcastCell.self)
        tableView.rowHeight = 100
        tableView.allowsSelection = true
        refreshControll.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.refreshControl = refreshControll
    }
    
    private func showEmptyImage() {
        let favoritePodcastsIsEmpty = FavoriteDocument.shared.favoritePodcastIsEmpty
        tableView.isHidden = favoritePodcastsIsEmpty
        emptyTableImageView.isHidden = !favoritePodcastsIsEmpty
        removeAllButton.isEnabled = !favoritePodcastsIsEmpty
    }
}

// MARK: - UITableViewDataSource
extension PlaylistTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let podcast = FavoriteDocument.shared.getPodcast(for: indexPath)
            delegate?.playlistTableViewControllerDidSelectStar(self, podcast: podcast)
//            tableView.deleteRows(at: [indexPath], with: .fade)
            showEmptyImage()
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoriteDocument.shared.countOffavoritePodcasts
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let podcast = FavoriteDocument.shared.getPodcast(for: indexPath)
        let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
        cell.addMyGestureRecognizer(self, type: .tap(), #selector(tapCell))
        cell.configureCell(with: podcast)
        cell.delegate = self
        
        return cell
    }
}

// MARK: - DetailViewControllerDelegate
extension PlaylistTableViewController : DetailViewControllerDelegate {
    func detailViewController(_ detailViewController: DetailViewController, addToFavoriteButtonDidTouchFor selectedPodcast: Podcast) {
        delegate?.playlistTableViewControllerDidSelectStar(self, podcast: selectedPodcast)
    }
    
    func detailViewController(_ detailViewController: DetailViewController, removeFromFavoriteButtonDidTouchFor selectedPodcast: Podcast) {
        delegate?.playlistTableViewControllerDidSelectStar(self, podcast: selectedPodcast)
    }
    
    func detailViewController(_ detailViewController: DetailViewController, playButtonDidTouchFor didSelectIndex: Int) {
        delegate?.playlistTableViewController(self, podcasts: FavoriteDocument.shared.podcasts, didSelectIndex: didSelectIndex)
    }
}

//MARK: - UIViewControllerTransitioningDelegate
extension PlaylistTableViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension PlaylistTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {}
}

//MARK: - PodcastCellDelegate
extension PlaylistTableViewController: PodcastCellDelegate {
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell, podcast: Podcast) {
        delegate?.playlistTableViewControllerDidSelectStar(self, podcast: podcast)
        showEmptyImage()
        tableView.reloadData()
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell, podcast: Podcast) {
        delegate?.playlistTableViewControllerDidSelectDownLoadImage(self, podcast: podcast)
        showEmptyImage()
        tableView.reloadData()
    }
}
