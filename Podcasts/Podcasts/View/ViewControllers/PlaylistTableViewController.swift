//
//  PlaylistTableViewController.swift
//  Podcasts
//
//  Created by mac on 26.10.2021.
//

import UIKit

class PlaylistTableViewController: UITableViewController {
    
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
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    }
    
}
