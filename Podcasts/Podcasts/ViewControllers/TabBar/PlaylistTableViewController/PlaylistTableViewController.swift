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
    func playlistTableViewControllerDidSelectStar(_ playlistTableViewController: PlaylistTableViewController, favoritePodcast: FavoritePodcast)
}

class PlaylistTableViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
 
    @IBOutlet private weak var emptyTableImageView: UIImageView!
    @IBOutlet private weak var removeAllButton: UIBarButtonItem!
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    weak var delegate: PlaylistViewControllerDelegate?
    private var tableViewBottomConstraintConstant: CGFloat = 0
    private let refreshControll = UIRefreshControl()
    
    private var playerIsSHidden = true {
        didSet {
            tableViewBottomConstraintConstant = playerIsSHidden ? 0 : 50
            tableViewBottomConstraint?.constant = tableViewBottomConstraintConstant
        }
    }
    
    //MARK: - Methods
    func playerIsHidden(_ bool: Bool) {
        playerIsSHidden = bool
    }
    
    func reloadData(indexPath: [IndexPath]) {
        tableView?.reloadRows(at: indexPath, with: .none)
        showEmptyImage()
    }
    
    func updateDisplay(progress: Float, totalSize: String, id: NSNumber) {
        guard let indexPath = FavoriteDocument.shared.getIndexPath(id: id),
              let podcastCell = tableView?.cellForRow(at: indexPath) as? PodcastCell
        else { return }
        
        podcastCell.updateDisplay(progress: progress, totalSize: totalSize)
    }

//     MARK: - View Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showEmptyImage()
        tableView.reloadData()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        tableViewBottomConstraint.constant = tableViewBottomConstraintConstant
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FavoriteDocument.shared.favoritePodcastFRC.delegate = self
    }
    
    //MARK: - Actions
    @IBAction func removeAllAction(_ sender: UIButton) {
        FavoriteDocument.shared.removaAllFavorites()
    }
    
    @objc func tapCell(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UITableViewCell,
              let indexPath = tableView.indexPath(for: view) else { return }
        
        let podcast = FavoriteDocument.shared.getPodcast(by: indexPath)
       
        let vc = DetailViewController.initVC
        vc.delegate = self
        vc.transitioningDelegate = self
        vc.setUp(index: indexPath.row, podcast: podcast)
        vc.modalPresentationStyle = .custom
        
        present(vc, animated: true)
    }
    
    @objc func refreshTableView() {
        FavoriteDocument.shared.updateFavoritePodcastFromFireBase { [weak self] result in
            switch result {
            case .failure(error: let error) :
                error.showAlert(vc: self)
            case .success(result: _) : break
            }
            self?.refreshControll.endRefreshing()
            self?.refreshControll.isHidden = true
        }
    }
}

//MARK: - Private methods
extension PlaylistTableViewController {
    
    private func configureUI() {
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
            let favoritePodcast = FavoriteDocument.shared.getFavoritePodcast(by: indexPath)
            delegate?.playlistTableViewControllerDidSelectStar(self, favoritePodcast: favoritePodcast)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoriteDocument.shared.favoritePodcastFRC.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return FavoriteDocument.shared.favoritePodcastFRC.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
        let podcast = FavoriteDocument.shared.getPodcast(by: indexPath)
        cell.configureCell(with: podcast)
        cell.delegate = self
        cell.addMyGestureRecognizer(self, type: .tap(), #selector(tapCell))
        return cell
    }
}

// MARK: - DetailViewControllerDelegate
extension PlaylistTableViewController : DetailViewControllerDelegate {
    func detailViewController(_ detailViewController: DetailViewController, addToFavoriteButtonDidTouchFor selectedPodcast: Podcast) {
        if let favoritePodcast = FavoriteDocument.shared.getFavoritePodcast(selectedPodcast) {
            delegate?.playlistTableViewControllerDidSelectStar(self, favoritePodcast: favoritePodcast)
        }
    }
    
    func detailViewController(_ detailViewController: DetailViewController, removeFromFavoriteButtonDidTouchFor selectedPodcast: Podcast) {
        guard let favoritePodcast = FavoriteDocument.shared.getFavoritePodcast(selectedPodcast),
              let indexPath = FavoriteDocument.shared.getIndexPath(for: favoritePodcast) else { return }
            delegate?.playlistTableViewControllerDidSelectStar(self, favoritePodcast: favoritePodcast)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .delete :
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .left)
            let title = "podcast is removed from playlist"
            MyToast.create(title: title, (playerIsSHidden ? .bottom : .bottomWithPlayer), for: view)
        case .insert :
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .left)
                let favoritePodcast = FavoriteDocument.shared.favoritePodcastFRC.object(at: newIndexPath)
                let name = favoritePodcast.podcast.trackName ?? ""
                let title = "\(name) podcast is added to playlist"
                MyToast.create(title: title, (playerIsSHidden ? .bottom : .bottomWithPlayer), for: view)
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
                let podcast = FavoriteDocument.shared.getPodcast(by: indexPath)
                if let cell = tableView.cellForRow(at: indexPath) as? PodcastCell {
                    cell.configureCell(with: podcast)
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

//MARK: - PodcastCellDelegate
extension PlaylistTableViewController: PodcastCellDelegate {
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell, podcast: Podcast) {
        if let favoritePodcast = FavoriteDocument.shared.getFavoritePodcast(podcast) {
            delegate?.playlistTableViewControllerDidSelectStar(self, favoritePodcast: favoritePodcast)
        }
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell, podcast: Podcast) {
        delegate?.playlistTableViewControllerDidSelectDownLoadImage(self, podcast: podcast)
    }
}
