//
//  PlaylistTableViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit
import CoreData

protocol PlaylistViewControllerDelegate : AnyObject {
    func playlistTableViewController(_ playlistTableViewController: PlaylistTableViewController, _ podcasts: [Podcast], didSelectIndex: Int)
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

    // MARK: - View Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playListTableView.reloadData()
        showEmptyImage()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        favoritePodcastFetchResultController.delegate = self
    }
    
    //MARK: - Actions
    @IBAction func removeAllAction(_ sender: UIButton) {
        Podcast.removeAll()
        playListTableView.reloadData()
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
        playListTableView.register(PodcastCell.self)
        navigationItem.title = "PlayList"
        playListTableView.rowHeight = 100
        playListTableView.allowsSelection = true
    }
    
    private func showEmptyImage() {
        playListTableView.isHidden = Podcast.favoritePodcasts.isEmpty
        emptyTableImageView.isHidden = !Podcast.favoritePodcasts.isEmpty
        removeAllButton.isEnabled = !Podcast.favoritePodcasts.isEmpty
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
        cell.addMyGestureRecognizer(self, type: .tap(1), selector: #selector(tapCell))
        cell.configureCell(with: podcast)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let podcast = Podcast.getfavoritePodcast(for: indexPath)
            Podcast.removeFromFavorites(podcast: podcast)
            tableView.reloadData()
            showEmptyImage()
        }
    }
}

// MARK: - DetailViewControllerDelegate
extension PlaylistTableViewController : DetailViewControllerDelegate {
    func detailViewController(_ detailViewController: DetailViewController, addButtonDidTouchFor selectedPodcast: Podcast) {
        Podcast.addToFavorites(podcast: selectedPodcast)
    }
    
    func detailViewController(_ detailViewController: DetailViewController, removeButtonDidTouchFor selectedPodcast: Podcast) {
        Podcast.removeFromFavorites(podcast: selectedPodcast)
        playListTableView.reloadData()
    }
    
    func detailViewController(_ detailViewController: DetailViewController, playButtonDidTouchFor didSelectIndex: Int) {
        delegate?.playlistTableViewController(self, Podcast.favoritePodcasts, didSelectIndex: didSelectIndex)
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
    }
}
