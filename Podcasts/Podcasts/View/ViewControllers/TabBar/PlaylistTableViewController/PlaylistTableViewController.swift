//
//  PlaylistTableViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit

protocol PlaylistTableViewControllerDelegate : AnyObject {
    func playlistTableViewController(_ playlistTableViewController: PlaylistTableViewController, _ podcasts: [Podcast], didSelectIndex: Int)
}

class PlaylistTableViewController: UITableViewController {
    
    private let cellHeight : CGFloat = 75.0
    
    weak var delegate: PlaylistTableViewControllerDelegate?

    // MARK: - View Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Actions
    @objc func trash(sender: UIBarButtonItem) {
        PlaylistDocument.shared.removeAllFromPlaylist()
        tableView.reloadData()
    }
}

//MARK: - Private methods
extension PlaylistTableViewController {
    
    private func configureUI() {
        tableView.register(PodcastCell.self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trash))
    }
}

// MARK: - Table View data source
extension PlaylistTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlaylistDocument.shared.playList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let podcast = PlaylistDocument.shared.playList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: PodcastCell.identifier, for: indexPath) as! PodcastCell
        cell.configureCell(with: podcast, indexPath)
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
        
        detailViewController.modalPresentationStyle = .custom
        detailViewController.transitioningDelegate = self
        present(detailViewController, animated: true, completion: nil)
        
   }
}

// MARK: - DetailViewControllerDelegate
extension PlaylistTableViewController : DetailViewControllerDelegate {
    
    func detailViewController(_ detailViewController: DetailViewController, playButtonDidTouchFor didSelectIndex: Int) {
        print("print count \(PlaylistDocument.shared.playList.count)")
        delegate?.playlistTableViewController(self, PlaylistDocument.shared.playList, didSelectIndex: didSelectIndex)
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
