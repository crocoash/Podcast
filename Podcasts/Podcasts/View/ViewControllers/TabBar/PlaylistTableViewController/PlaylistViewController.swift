//
//  PlaylistTableViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    @IBOutlet private weak var playListTableView: UITableView!
    @IBOutlet private weak var playerConstraint: NSLayoutConstraint!
        
    weak var delegate: PlaylistTableViewControllerDelegate?
    
    lazy private var detailViewController: DetailViewController = {
        let detailViewController = storyboard?.instantiateViewController(identifier: DetailViewController.identifier) as! DetailViewController
        detailViewController.delegate = self
        detailViewController.transitioningDelegate = self
        return detailViewController
    }()
    
    // MARK: - View Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playListTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Actions
    @objc func trash(sender: UIBarButtonItem) {
        PlaylistDocument.shared.removeAllFromPlaylist()
        playListTableView.reloadData()
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
extension PlaylistViewController {
    
    private func configureUI() {
        playListTableView.register(PodcastCell.self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trash))
        playListTableView.rowHeight = 100
        playListTableView.allowsSelection = true
    }
}

// MARK: - Table View data source
extension PlaylistViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlaylistDocument.shared.playList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let podcast = PlaylistDocument.shared.playList[indexPath.row]
        let cell = playListTableView.dequeueReusableCell(withIdentifier: PodcastCell.identifier, for: indexPath) as! PodcastCell
        cell.addMyGestureRecognizer(self, type: .tap(1), selector: #selector(tapCell))
        cell.configureCell(with: podcast)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let podcast = PlaylistDocument.shared.playList[indexPath.row]
            PlaylistDocument.shared.removeFromPlayList(podcast)
            tableView.reloadData()
        }
    }
}

// MARK: - DetailViewControllerDelegate
extension PlaylistViewController : DetailViewControllerDelegate {
    
    func detailViewController(_ detailViewController: DetailViewController, playButtonDidTouchFor didSelectIndex: Int) {
        delegate?.playlistTableViewController(self, PlaylistDocument.shared.playList, didSelectIndex: didSelectIndex)
    }
}

//MARK: - UIViewControllerTransitioningDelegate
extension PlaylistViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }
}
