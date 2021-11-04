//
//  PlaylistTableViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit

protocol PlaylistTableViewControllerDelegate : AnyObject {
    func playlistTableViewController(_ playlistTableViewController: PlaylistTableViewController, play podcasts: [Podcast], at index: Int)
}

class PlaylistTableViewController: UITableViewController {
    
    private let cellHeight : CGFloat = 75.0
    
    weak var delegate: PlaylistTableViewControllerDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        guard let urlString = podcast.artworkUrl160, let url = URL(string: urlString), let trackName = podcast.trackName, let collectionName = podcast.collectionName, let description = podcast.description else { return }
        let detailViewController = storyboard?.instantiateViewController(identifier: DetailViewController.identifier) as! DetailViewController
        detailViewController.delegate = self
        let image = UIImageView()
        image.load(url: url)
        detailViewController.receivePodcastInfoAndIndex(index: indexPath.row, image: image, episode: trackName, collection: collectionName, episodeDescription: description)
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    }
    
}

// MARK: - DetailViewControllerDelegate
extension PlaylistTableViewController : DetailViewControllerDelegate {
    func detailViewController(_ detailViewController: DetailViewController, playButtonDidTouchFor podcastIndex: Int) {
        delegate?.playlistTableViewController(self, play: PlaylistDocument.shared.playList, at: podcastIndex)
    }
}
