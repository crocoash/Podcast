//
//  LikedMomentsViewController.swift
//  Podcasts
//
//  Created by mac on 08.11.2021.
//

import UIKit

protocol LikedMomentsViewControllerDelegate: AnyObject {
    func likedMomentViewController(_ likedMomentViewController: LikedMomentsViewController, didSelectMomentAt index: Int, likedMoments: [LikedMoment])
}

class LikedMomentsViewController: UIViewController {

    @IBOutlet private weak var emptyDataImage: UIImageView!
    @IBOutlet private weak var likedMomentsTableView: UITableView!
    
    private var cellHeight: CGFloat = 75
    weak var delegate: LikedMomentsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        likedMomentsTableView.register(PodcastCell.self)
        likedMomentsTableView.rowHeight = cellHeight
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        likedMomentsTableView.reloadData()
        reloadData()
    }
    
    func reloadData() {
        likedMomentsTableView?.reloadData()
        showEmptyImage()
    }
}

extension LikedMomentsViewController {
    
    private func showEmptyImage() {
        let likeMomentsIsEmpty = LikedMomentsManager.shared.likeMoments.isEmpty
        emptyDataImage?.isHidden = !likeMomentsIsEmpty
        likedMomentsTableView?.isHidden = likeMomentsIsEmpty
    }
}

extension LikedMomentsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.likedMomentViewController(self, didSelectMomentAt: indexPath.row, likedMoments: LikedMomentsManager.shared.likeMoments)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //TODO: - beginUpdates()
            likedMomentsTableView.beginUpdates()
            LikedMomentsManager.shared.deleteMoment(at: indexPath)
            likedMomentsTableView.deleteRows(at: [indexPath], with: .fade)
            likedMomentsTableView.endUpdates()
            reloadData()
        }
    }
}

extension LikedMomentsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LikedMomentsManager.shared.countOfLikeMoments
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let likedMoment = LikedMomentsManager.shared.getLikeMoment(at: indexPath)
        let cell = likedMomentsTableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
        
        cell.configureCell(with: likedMoment.podcast)
        return cell
    }
}
