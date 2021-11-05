//
//  PlaylistTableViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit

protocol PlaylistTableViewControllerDelegate : AnyObject {
    // FIXME: Что значит "play podcasts"? Я так понимаю, что были выбраны подкасты и кто-то должен начать их воспроизводить. Но мы помним, что делегат НЕ МОЖЕТ ГОВОРИТЬ ЧТО ДЕЛАТЬ, а говорит о то, что он сделал. Например didSelect podcasts: [Podcast]
    func playlistTableViewController(_ playlistTableViewController: PlaylistTableViewController, play podcasts: [Podcast], at index: Int)
}

class PlaylistTableViewController: UITableViewController {
    
    private let cellHeight : CGFloat = 75.0
    
    weak var delegate: PlaylistTableViewControllerDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData() // FIXME: В приватный метод
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // FIXME: В приватный метод
        print("print playlist \(PlaylistDocument.shared.playList.count)")
        tableView.register(PodcastCell.self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trash))
    }
}

// MARK: - Table view data source
extension PlaylistTableViewController {
    @objc func trash(sender: UIBarButtonItem) {
        PlaylistDocument.shared.removeAllFromPlaylist()
        tableView.reloadData()
    }
}

extension PlaylistTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // FIXME: Плейлист документ можно в проперти добавить, чтобы не писать каждый раз PlaylistDocument.shared
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
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        // FIXME: Нужно ли оно тут? Удаляем, если не нужно
    }
    
}

// MARK: - DetailViewControllerDelegate
extension PlaylistTableViewController : DetailViewControllerDelegate {
    func detailViewController(_ detailViewController: DetailViewController, playButtonDidTouchFor podcastIndex: Int) {
        delegate?.playlistTableViewController(self, play: PlaylistDocument.shared.playList, at: podcastIndex)
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
