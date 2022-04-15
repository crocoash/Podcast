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
    func playlistTableViewControllerDidSelectDownLoadButton(_ playlistTableViewController: PlaylistTableViewController, podcast: Podcast)
}

class PlaylistTableViewController: UIViewController {
    
    @IBOutlet private weak var playListTableView: UITableView!
    @IBOutlet private weak var playerConstraint: NSLayoutConstraint!
    @IBOutlet private weak var emptyTableImageView: UIImageView!
    @IBOutlet private weak var removeAllButton: UIBarButtonItem!
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    weak var delegate: PlaylistViewControllerDelegate?
    private let favoritePodcastFetchResultController = DataStoreManager.shared.favoritePodcastFetchResultController
    
    func playerIsShow() {
        tableViewBottomConstraint.constant = -50
    }
    
    func getIndexPath(for podcast: Podcast) -> IndexPath? {
        return favoritePodcastFetchResultController.indexPath(forObject: podcast)
    }
    
    func updateDisplay(progress: Float, totalSize: String, podcast: Podcast) {
        guard let indexPath = favoritePodcastFetchResultController.indexPath(forObject: podcast) else { return }
        if let podcastCell = self.playListTableView?.cellForRow(at: indexPath) as? PodcastCell {
            podcastCell.updateDisplay(progress: progress, totalSize: totalSize)
        }
    }

    // MARK: - View Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showEmptyImage()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Actions
    @IBAction func removeAllAction(_ sender: UIButton) {
        Podcast.removaAllFavorites()
        showEmptyImage()
    }
    
    @objc func tapCell(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UITableViewCell,
              let indexPath = playListTableView.indexPath(for: view) else { return }
        
        let podcast = Podcast.getfavoritePodcast(for: indexPath)
       
        let vc = DetailViewController.initVC
        vc.delegate = self
        vc.transitioningDelegate = self
        vc.setUp(index: indexPath.row, podcast: podcast)
        vc.modalPresentationStyle = .custom
        
        present(vc, animated: true)
    }
}

//MARK: - Private methods
extension PlaylistTableViewController {
    private func configureUI() {
        favoritePodcastFetchResultController.delegate = self
        playListTableView.register(PodcastCell.self)
        navigationItem.title = "PlayList"
        playListTableView.rowHeight = 100
        playListTableView.allowsSelection = true
    }
    
    private func showEmptyImage() {
        let favoritePodcastsIsEmpty = favoritePodcastFetchResultController.fetchedObjects?.isEmpty ?? true
        playListTableView.isHidden = favoritePodcastsIsEmpty
        emptyTableImageView.isHidden = !favoritePodcastsIsEmpty
        removeAllButton.isEnabled = !favoritePodcastsIsEmpty
        playListTableView.reloadData()
    }
}

// MARK: - Table View data source
extension PlaylistTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = favoritePodcastFetchResultController.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let podcast = Podcast.getfavoritePodcast(for: indexPath)
        let cell = playListTableView.dequeueReusableCell(withIdentifier: PodcastCell.identifier, for: indexPath) as! PodcastCell
        cell.addMyGestureRecognizer(self, type: .tap(), selector: #selector(tapCell))
        cell.configureCell(with: podcast)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let podcast = favoritePodcastFetchResultController.object(at: indexPath)
            Podcast.removeFromFavorites(podcast: podcast)
            tableView.reloadData()
            showEmptyImage()
        } else if editingStyle == .insert {
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - DetailViewControllerDelegate
extension PlaylistTableViewController : DetailViewControllerDelegate {
    func detailViewController(_ detailViewController: DetailViewController, addToFavoriteButtonDidTouchFor selectedPodcast: Podcast) {
        selectedPodcast.isFavorite = true
        DataStoreManager.shared.viewContext.mySave()
    }
    
    func detailViewController(_ detailViewController: DetailViewController, removeFromFavoriteButtonDidTouchFor selectedPodcast: Podcast) {
            Podcast.removeFromFavorites(podcast: selectedPodcast)
            showEmptyImage()
    }
    
    func detailViewController(_ detailViewController: DetailViewController, playButtonDidTouchFor didSelectIndex: Int) {
        delegate?.playlistTableViewController(self,podcasts: Podcast.favoritePodcasts, didSelectIndex: didSelectIndex)
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
        guard let indexPath = indexPath else { return }
        
        switch type {
        case .insert:
            playListTableView.insertRows(at: [indexPath], with: .none)
        case .delete:
            playListTableView.deleteRows(at: [indexPath], with: .none)
        default: break
        }
    }
}

//MARK: - PodcastCellDelegate
extension PlaylistTableViewController: PodcastCellDelegate {
    func podcastCellDidSelectStar(_ podcastCell: PodcastCell, podcast: Podcast) {
        Podcast.removeFromFavorites(podcast: podcast)
        showEmptyImage()
    }
    
    func podcastCellDidSelectDownLoadImage(_ podcastCell: PodcastCell, podcast: Podcast) {
        delegate?.playlistTableViewControllerDidSelectDownLoadButton(self, podcast: podcast)
    }
}
