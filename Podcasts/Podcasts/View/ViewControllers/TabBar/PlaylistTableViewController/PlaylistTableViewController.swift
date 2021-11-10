//
//  PlaylistTableViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit

class PlaylistTableViewController: UITableViewController {
    
    @IBOutlet private weak var playListTableView: UITableView!
    @IBOutlet private weak var playerConstraint: NSLayoutConstraint!
    @IBOutlet private weak var emptyTableImageView: UIImageView!
    
    weak var delegate: PlaylistTableViewControllerDelegate?
    
    lazy private var detailViewController: DetailViewController = {
        let detailViewController = storyboard?.instantiateViewController(identifier: DetailViewController.identifier) as! DetailViewController
        detailViewController.delegate = self
        detailViewController.transitioningDelegate = self
        return detailViewController
    }()
    
    weak var delegate: PlaylistTableViewControllerDelegate?

    // MARK: - View Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playListTableView.reloadData()
        showEmptyImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Actions
    @objc func trash(sender: UIBarButtonItem) {
        PlaylistDocument.shared.removeAllFromPlaylist()
        playListTableView.reloadData()
        showEmptyImage()
    }
    
    @objc func tapCell(sender: UITapGestureRecognizer) {
        
        guard let view = sender.view as? UITableViewCell,
              let indexPath = playListTableView.indexPath(for: view) else { return }
        
        let podcast = PlaylistDocument.shared.playList[indexPath.row]
        detailViewController.setUp(index: indexPath.row, podcast: podcast)
        detailViewController.modalPresentationStyle = .custom
        present(detailViewController, animated: true, completion: nil)
    }
}

//MARK: - Private methods
extension PlaylistTableViewController {
    
    private func configureUI() {
        playListTableView.register(PodcastCell.self)
        navigationItem.title = "PlayList"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trash))
        playListTableView.rowHeight = 100
        playListTableView.allowsSelection = true
    }
}

// MARK: - Table View data source
extension PlaylistTableViewController {
    
    private func showEmptyImage() {
        
        if PlaylistDocument.shared.playList.isEmpty {
            playListTableView.isHidden = true
            emptyTableImageView.isHidden = false
        }
        
        if !PlaylistDocument.shared.playList.isEmpty {
            playListTableView.isHidden = false
            emptyTableImageView.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlaylistDocument.shared.playList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let podcast = PlaylistDocument.shared.playList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: PodcastCell.identifier, for: indexPath) as! PodcastCell
        cell.configureCell(with: podcast)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let podcast = PlaylistDocument.shared.playList[indexPath.row]
            PlaylistDocument.shared.removeFromPlayList(podcast)
            tableView.reloadData()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let podcast = PlaylistDocument.shared.playList[indexPath.row]
        
        let detailViewController = storyboard?.instantiateViewController(identifier: DetailViewController.identifier) as! DetailViewController
        
        detailViewController.delegate = self
        detailViewController.setUp(index: indexPath.row, podcast: podcast)
        detailViewController.title = "Additional info"
        
        self.navigationController?.pushViewController(detailViewController, animated: true)
        
   }
}

// MARK: - DetailViewControllerDelegate
extension PlaylistTableViewController : DetailViewControllerDelegate {
    
    func detailViewController(_ detailViewController: DetailViewController, playButtonDidTouchFor didSelectIndex: Int) {
        delegate?.playlistTableViewController(self, PlaylistDocument.shared.playList, didSelectIndex: didSelectIndex)
    }
    
    func detailViewController(_ detailViewController: DetailViewController, addButtonDidTouchFor selectedPodcast: Podcast) {
        PlaylistDocument.shared.addToPlayList(selectedPodcast)
    }
    
    func detailViewController(_ detailViewController: DetailViewController, removeButtonDidTouchFor selectedPodcast: Podcast) {
        PlaylistDocument.shared.removeFromPlayList(selectedPodcast)
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
