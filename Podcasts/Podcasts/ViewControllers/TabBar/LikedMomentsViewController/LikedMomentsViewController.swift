//
//  LikedMomentsViewController.swift
//  Podcasts
//
//  Created by mac on 08.11.2021.
//

import UIKit

protocol LikedMomentsViewControllerDelegate: AnyObject {
    func likedMomentViewController(_ likedMomentViewController: LikedMomentsViewController, didSelectMomentAt index: Int)
}

class LikedMomentsViewController: UIViewController {

    @IBOutlet private weak var emptyDataImage: UIImageView!
    @IBOutlet private weak var likedMomentsTableView: UITableView!
    
    private var cellHeight: CGFloat = 75
    weak var delegate: LikedMomentsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeOnDataSourceAndDelegate()
        likedMomentsTableView.register(PodcastCell.self)
        likedMomentsTableView.rowHeight = cellHeight
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        likedMomentsTableView.reloadData()
        configureUI()
    }
    
    func subscribeOnDataSourceAndDelegate() {
        likedMomentsTableView.delegate = self
        likedMomentsTableView.dataSource = self
    }
}

extension LikedMomentsViewController {
    
    private func configureUI() {
        emptyDataImage.isHidden = !LikedMomentsManager.shared().getLikedMomentsFromUserDefault().isEmpty
        likedMomentsTableView.isHidden = LikedMomentsManager.shared().getLikedMomentsFromUserDefault().isEmpty
    }
}

extension LikedMomentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.likedMomentViewController(self, didSelectMomentAt: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            likedMomentsTableView.beginUpdates()
            LikedMomentsManager.shared().deleteMoment(at: indexPath.row)
            likedMomentsTableView.deleteRows(at: [indexPath], with: .fade)
            likedMomentsTableView.endUpdates()
            configureUI()
        }
    }
}

extension LikedMomentsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LikedMomentsManager.shared().getLikedMomentsFromUserDefault().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let podcast = LikedMomentsManager.shared().getLikedMomentsFromUserDefault()[indexPath.row].podcast
        let cell = likedMomentsTableView.dequeueReusableCell(withIdentifier: PodcastCell.identifier, for: indexPath) as! PodcastCell

        cell.configureCell(with: podcast)
        return cell
    }
}
