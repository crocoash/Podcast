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
    
    @IBOutlet private weak var playListTableView: UITableView!
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
    
    func updateDisplay(progress: Float, totalSize: String, podcast: Podcast) {
        guard let indexPath = FavoriteDocument.shared.getIndexPath(for: podcast),
              let podcastCell = self.playListTableView?.cellForRow(at: indexPath) as? PodcastCell else { return }
      
        podcastCell.updateDisplay(progress: progress, totalSize: totalSize)
    }
    
    func reloadData() {
        showEmptyImage()
        playListTableView.reloadData()
    }

    // MARK: - View Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showEmptyImage()
        playListTableView.reloadData()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Actions
    @IBAction func removeAllAction(_ sender: UIButton) {
        FavoriteDocument.shared.removaAllFavorites()
        FirebaseDatabase.shared.save()
        showEmptyImage()
    }
    
    @objc func tapCell(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UITableViewCell,
              let indexPath = playListTableView.indexPath(for: view) else { return }
        
        let podcast = FavoriteDocument.shared.getfavoritePodcast(for: indexPath)
       
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
            self?.playListTableView.reloadData()
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
        playListTableView.register(PodcastCell.self)
        playListTableView.rowHeight = 100
        playListTableView.allowsSelection = true
        refreshControll.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        playListTableView.refreshControl = refreshControll
    }
    
    private func showEmptyImage() {
        let favoritePodcastsIsEmpty = FavoriteDocument.shared.favoritePodcastIsEmpty
        playListTableView.isHidden = favoritePodcastsIsEmpty
        emptyTableImageView.isHidden = !favoritePodcastsIsEmpty
        removeAllButton.isEnabled = !favoritePodcastsIsEmpty
    }
}

// MARK: - Table View data source
extension PlaylistTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoriteDocument.shared.favoritePodcasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let podcast = FavoriteDocument.shared.getfavoritePodcast(for: indexPath)
        let cell = playListTableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
        cell.addMyGestureRecognizer(self, type: .tap(), selector: #selector(tapCell))
        cell.configureCell(with: podcast)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let podcast = FavoriteDocument.shared.getfavoritePodcast(for: indexPath)
//            FavoriteDocument.shared.removeFromFavorites(podcast: podcast)
//            tableView.reloadData()
//            showEmptyImage()
//        } else if editingStyle == .insert {
//            tableView.insertRows(at: [indexPath], with: .automatic)
//        }
    }
}

// MARK: - DetailViewControllerDelegate
extension PlaylistTableViewController : DetailViewControllerDelegate {
    func detailViewController(_ detailViewController: DetailViewController, addToFavoriteButtonDidTouchFor selectedPodcast: Podcast) {
        selectedPodcast.isFavorite = true
        DataStoreManager.shared.mySave()
    }
    
    func detailViewController(_ detailViewController: DetailViewController, removeFromFavoriteButtonDidTouchFor selectedPodcast: Podcast) {
        FavoriteDocument.shared.addOrRemoveToFavorite(podcast: selectedPodcast)
    }
    
    func detailViewController(_ detailViewController: DetailViewController, playButtonDidTouchFor didSelectIndex: Int) {
        delegate?.playlistTableViewController(self,podcasts: FavoriteDocument.shared.favoritePodcasts, didSelectIndex: didSelectIndex)
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
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        //TODO: -
//        guard let indexPath = indexPath else { return }
//
//        switch type {
//        case .insert:
//            playListTableView.insertRows(at: [indexPath], with: .none)
//        case .delete:
//            playListTableView.deleteRows(at: [indexPath], with: .none)
//        default: break
//        }
    }
}

//MARK: - PodcastCellDelegate
extension PlaylistTableViewController: PodcastCellDelegate {
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell, podcast: Podcast) {
        delegate?.playlistTableViewControllerDidSelectStar(self, podcast: podcast)
        showEmptyImage()
        playListTableView.reloadData()
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell, podcast: Podcast) {
        delegate?.playlistTableViewControllerDidSelectDownLoadImage(self, podcast: podcast)
        showEmptyImage()
        playListTableView.reloadData()
    }
}
